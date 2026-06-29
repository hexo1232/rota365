import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:api_compartilhado/api_compartilhado.dart';

class UsuarioFormScreen extends StatefulWidget {
  const UsuarioFormScreen({super.key});

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _senhaController = TextEditingController();

  UsuarioModel? _usuarioEdicao;
  bool _carregouArgumentos = false;
  int? _idPerfilSelecionado;

  /*
   * Temporário:
   * Depois substituímos por GET /api/perfis.
   */
  final List<_PerfilOpcao> _perfis = const [
    _PerfilOpcao(id: 1, nome: 'Administrador', icon: Icons.admin_panel_settings_rounded),
    _PerfilOpcao(id: 2, nome: 'Gerente', icon: Icons.manage_accounts_rounded),
    _PerfilOpcao(id: 3, nome: 'Operador', icon: Icons.point_of_sale_rounded),
    _PerfilOpcao(id: 4, nome: 'Vendedor', icon: Icons.confirmation_number_rounded),
  ];

  bool get _modoEdicao => _usuarioEdicao != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_carregouArgumentos) return;
    _carregouArgumentos = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is UsuarioModel) {
      _usuarioEdicao = args;
      _nomeController.text = args.nome;
      _usernameController.text = args.username;
      _idPerfilSelecionado = args.idPerfil;
    } else {
      _idPerfilSelecionado = _perfis.first.id;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _usernameController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UsuarioProvider>();

    final nome = _nomeController.text.trim();
    final username = _usernameController.text.trim();
    final senhaDigitada = _senhaController.text.trim();

    bool sucesso;

    if (_modoEdicao) {
      sucesso = await provider.atualizarUsuario(
        idUsuario: _usuarioEdicao!.idUsuario,
        nome: nome,
        username: username,
        senha: senhaDigitada.isEmpty ? null : senhaDigitada,
        idPerfil: _idPerfilSelecionado,
      );
    } else {
      /*
       * Enviamos senha null/vazia para o backend aplicar a senha padrão.
       * Regra esperada no Java:
       * SENHA_PADRAO = "12345678"
       */
      sucesso = await provider.criarUsuario(
        nome: nome,
        username: username,
        senha: senhaDigitada.isEmpty ? null : senhaDigitada,
        idPerfil: _idPerfilSelecionado,
      );
    }

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modoEdicao
                ? 'Usuário actualizado com sucesso.'
                : 'Usuário criado com sucesso. Senha padrão: 12345678.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      _mostrarErro(provider.erro ?? 'Não foi possível salvar o usuário.');
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Color _corPerfil(String nome) {
    final perfil = nome.toLowerCase();

    if (perfil.contains('admin')) return Colors.deepPurple;
    if (perfil.contains('gerente')) return Colors.blue;
    if (perfil.contains('operador') || perfil.contains('vendedor')) return Colors.green;

    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _modoEdicao ? 'Editar usuário' : 'Novo usuário';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          Consumer<UsuarioProvider>(
            builder: (context, provider, _) {
              return TextButton.icon(
                onPressed: provider.isLoading ? null : _salvar,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Salvar'),
              );
            },
          ),
        ],
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _CabecalhoForm(
                      modoEdicao: _modoEdicao,
                      usuario: _usuarioEdicao,
                    ),

                    const SizedBox(height: 16),

                    if (provider.erro != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          provider.erro!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),

                    _CardSecao(
                      titulo: 'Dados do usuário',
                      icon: Icons.person_rounded,
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nome completo',
                            hintText: 'Ex: Matias Matavel',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) {
                              return 'Informe o nome do usuário.';
                            }

                            if (text.length > 100) {
                              return 'O nome deve ter no máximo 100 caracteres.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'Ex: matias',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) {
                              return 'Informe o username.';
                            }

                            if (text.length > 50) {
                              return 'O username deve ter no máximo 50 caracteres.';
                            }

                            if (text.contains(' ')) {
                              return 'O username não deve conter espaços.';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _CardSecao(
                      titulo: 'Perfil de acesso',
                      icon: Icons.admin_panel_settings_rounded,
                      children: [
                        DropdownButtonFormField<int>(
                          value: _idPerfilSelecionado,
                          decoration: const InputDecoration(
                            labelText: 'Perfil',
                            prefixIcon: Icon(Icons.shield_rounded),
                            border: OutlineInputBorder(),
                          ),
                          items: _perfis.map((perfil) {
                            final cor = _corPerfil(perfil.nome);

                            return DropdownMenuItem<int>(
                              value: perfil.id,
                              child: Row(
                                children: [
                                  Icon(
                                    perfil.icon,
                                    size: 20,
                                    color: cor,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(perfil.nome),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: provider.isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _idPerfilSelecionado = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Escolha o perfil do usuário.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        _PerfilPreview(
                          perfil: _perfis.firstWhere(
                            (p) => p.id == _idPerfilSelecionado,
                            orElse: () => _perfis.first,
                          ),
                          cor: _corPerfil(
                            _perfis
                                .firstWhere(
                                  (p) => p.id == _idPerfilSelecionado,
                                  orElse: () => _perfis.first,
                                )
                                .nome,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _CardSecao(
                      titulo: 'Senha',
                      icon: Icons.lock_rounded,
                      children: [
                        TextFormField(
                          controller: _senhaController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: _modoEdicao
                                ? 'Nova senha opcional'
                                : 'Senha opcional',
                            hintText: _modoEdicao
                                ? 'Deixe vazio para manter a senha actual'
                                : 'Deixe vazio para usar 12345678',
                            prefixIcon: const Icon(Icons.password_rounded),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) return null;

                            if (text.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres.';
                            }

                            if (text.length > 100) {
                              return 'A senha deve ter no máximo 100 caracteres.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        _AvisoSenhaPadrao(
                          modoEdicao: _modoEdicao,
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: provider.isLoading ? null : _salvar,
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          provider.isLoading
                              ? 'A guardar...'
                              : _modoEdicao
                                  ? 'Actualizar usuário'
                                  : 'Criar usuário',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (provider.isLoading)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CabecalhoForm extends StatelessWidget {
  final bool modoEdicao;
  final UsuarioModel? usuario;

  const _CabecalhoForm({
    required this.modoEdicao,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = modoEdicao ? 'Actualizar dados' : 'Cadastrar novo usuário';

    final subtitulo = modoEdicao
        ? 'Altere os dados do usuário seleccionado.'
        : 'Preencha os dados do operador que terá acesso ao sistema.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: Icon(
              modoEdicao
                  ? Icons.manage_accounts_rounded
                  : Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                if (usuario != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '@${usuario!.username}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.86),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSecao extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final List<Widget> children;

  const _CardSecao({
    required this.titulo,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _PerfilPreview extends StatelessWidget {
  final _PerfilOpcao perfil;
  final Color cor;

  const _PerfilPreview({
    required this.perfil,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    String descricao;

    final nome = perfil.nome.toLowerCase();

    if (nome.contains('admin')) {
      descricao = 'Acesso máximo às configurações e gestão do sistema.';
    } else if (nome.contains('gerente')) {
      descricao = 'Acesso à gestão operacional e acompanhamento das vendas.';
    } else if (nome.contains('operador') || nome.contains('vendedor')) {
      descricao = 'Acesso às operações de venda de bilhetes no balcão.';
    } else {
      descricao = 'Perfil de acesso personalizado.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Icon(
            perfil.icon,
            color: cor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              descricao,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoSenhaPadrao extends StatelessWidget {
  final bool modoEdicao;

  const _AvisoSenhaPadrao({
    required this.modoEdicao,
  });

  @override
  Widget build(BuildContext context) {
    final texto = modoEdicao
        ? 'Ao deixar este campo vazio, a senha actual será mantida.'
        : 'Ao deixar este campo vazio, o usuário será criado com a senha padrão 12345678.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.amber.shade900,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfilOpcao {
  final int id;
  final String nome;
  final IconData icon;

  const _PerfilOpcao({
    required this.id,
    required this.nome,
    required this.icon,
  });
}