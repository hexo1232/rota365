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

  UsuarioModel? _usuarioEdicao;
  bool _carregouArgumentos = false;
  bool _carregouPerfis = false;
  int? _idPerfilSelecionado;

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
    }

    Future.microtask(() async {
      final provider = context.read<UsuarioProvider>();

      await provider.carregarPerfis();

      if (!mounted) return;

      final perfis = provider.perfis;

      if (perfis.isEmpty) {
        return;
      }

      final existePerfilSelecionado = perfis.any(
        (perfil) => perfil.idPerfil == _idPerfilSelecionado,
      );

      if (_idPerfilSelecionado == null || !existePerfilSelecionado) {
        setState(() {
          _idPerfilSelecionado = perfis.first.idPerfil;
          _carregouPerfis = true;
        });
      } else {
        setState(() {
          _carregouPerfis = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UsuarioProvider>();

    final nome = _nomeController.text.trim();
    final username = _usernameController.text.trim();

    bool sucesso;

    if (_modoEdicao) {
      sucesso = await provider.atualizarUsuario(
        idUsuario: _usuarioEdicao!.idUsuario,
        nome: nome,
        username: username,
        idPerfil: _idPerfilSelecionado,
      );
    } else {
      sucesso = await provider.criarUsuario(
        nome: nome,
        username: username,
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
    final perfil = nome.toLowerCase().trim();

    if (perfil.contains('gerente')) return Colors.blue;
    if (perfil.contains('operador')) return Colors.green;
    if (perfil.contains('vendedor')) return Colors.teal;
    if (perfil.contains('cliente')) return Colors.orange;

    return Colors.blueGrey;
  }

  IconData _iconePerfil(String nome) {
    final perfil = nome.toLowerCase().trim();

    if (perfil.contains('gerente')) {
      return Icons.manage_accounts_rounded;
    }

    if (perfil.contains('operador')) {
      return Icons.point_of_sale_rounded;
    }

    if (perfil.contains('vendedor')) {
      return Icons.confirmation_number_rounded;
    }

    if (perfil.contains('cliente')) {
      return Icons.person_rounded;
    }

    return Icons.shield_rounded;
  }

  String _descricaoPerfil(String nome) {
    final perfil = nome.toLowerCase().trim();

    if (perfil.contains('gerente')) {
      return 'Acesso à gestão operacional e acompanhamento das vendas.';
    }

    if (perfil.contains('operador')) {
      return 'Acesso às operações diárias do balcão e apoio à venda.';
    }

    if (perfil.contains('vendedor')) {
      return 'Acesso à venda de bilhetes e operações comerciais.';
    }

    if (perfil.contains('cliente')) {
      return 'Perfil reservado para clientes ou acessos limitados.';
    }

    return 'Perfil de acesso operacional.';
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
          final perfis = provider.perfis
              .where((perfil) => !perfil.isAdministrador)
              .toList();

          final perfilSelecionado = perfis
              .where((perfil) => perfil.idPerfil == _idPerfilSelecionado)
              .cast<PerfilUsuarioModel?>()
              .firstOrNull;

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
                          textInputAction: TextInputAction.done,
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
                        if (provider.isLoading && !_carregouPerfis)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (perfis.isEmpty)
                          const _SemPerfisDisponiveis()
                        else ...[
                          DropdownButtonFormField<int>(
                            value: _idPerfilSelecionado,
                            decoration: const InputDecoration(
                              labelText: 'Perfil',
                              prefixIcon: Icon(Icons.shield_rounded),
                              border: OutlineInputBorder(),
                            ),
                            items: perfis.map((perfil) {
                              final cor = _corPerfil(perfil.nomePerfil);

                              return DropdownMenuItem<int>(
                                value: perfil.idPerfil,
                                child: Row(
                                  children: [
                                    Icon(
                                      _iconePerfil(perfil.nomePerfil),
                                      size: 20,
                                      color: cor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(perfil.nomePerfil),
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

                          if (perfilSelecionado != null) ...[
                            const SizedBox(height: 12),
                            _PerfilPreview(
                              nomePerfil: perfilSelecionado.nomePerfil,
                              icon: _iconePerfil(
                                perfilSelecionado.nomePerfil,
                              ),
                              cor: _corPerfil(
                                perfilSelecionado.nomePerfil,
                              ),
                              descricao: _descricaoPerfil(
                                perfilSelecionado.nomePerfil,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    const _AvisoSenhaAutomatica(),

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
        : 'Preencha os dados do usuário que terá acesso ao sistema.';

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
  final String nomePerfil;
  final IconData icon;
  final Color cor;
  final String descricao;

  const _PerfilPreview({
    required this.nomePerfil,
    required this.icon,
    required this.cor,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
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
            icon,
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

class _AvisoSenhaAutomatica extends StatelessWidget {
  const _AvisoSenhaAutomatica();

  @override
  Widget build(BuildContext context) {
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
              'A senha não é definida neste cadastro. O backend criará automaticamente a senha padrão 12345678.',
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

class _SemPerfisDisponiveis extends StatelessWidget {
  const _SemPerfisDisponiveis();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade800,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nenhum perfil operacional encontrado. Verifique se a tabela perfil possui Gerente, Vendedor, Cliente ou outro perfil diferente de Administrador.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}