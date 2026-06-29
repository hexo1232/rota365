import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:api_compartilhado/api_compartilhado.dart';

enum UsuarioFiltroStatus {
  todos,
  ativos,
  inativos,
}

class UsuarioListScreen extends StatefulWidget {
  const UsuarioListScreen({super.key});

  @override
  State<UsuarioListScreen> createState() => _UsuarioListScreenState();
}

class _UsuarioListScreenState extends State<UsuarioListScreen> {
  UsuarioFiltroStatus _filtro = UsuarioFiltroStatus.todos;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UsuarioProvider>().carregarTodos();
    });
  }

  Future<void> _aplicarFiltro(UsuarioFiltroStatus filtro) async {
    setState(() {
      _filtro = filtro;
    });

    final provider = context.read<UsuarioProvider>();

    switch (filtro) {
      case UsuarioFiltroStatus.todos:
        await provider.carregarTodos();
        break;

      case UsuarioFiltroStatus.ativos:
        await provider.carregarAtivos();
        break;

      case UsuarioFiltroStatus.inativos:
        await provider.carregarInativos();
        break;
    }
  }

  Future<void> _toggleAtivo(UsuarioModel usuario) async {
    final provider = context.read<UsuarioProvider>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        final vaiDesativar = usuario.ativo;

        return AlertDialog(
          title: Text(vaiDesativar ? 'Desactivar usuário' : 'Activar usuário'),
          content: Text(
            vaiDesativar
                ? 'Deseja desactivar o usuário "${usuario.nome}"?'
                : 'Deseja activar o usuário "${usuario.nome}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(vaiDesativar ? 'Desactivar' : 'Activar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    final sucesso = await provider.toggleAtivo(usuario.idUsuario);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usuario.ativo
                ? 'Usuário desactivado com sucesso.'
                : 'Usuário activado com sucesso.',
          ),
        ),
      );
    } else {
      _mostrarErro(provider.erro ?? 'Não foi possível alterar o estado.');
    }
  }

  Future<void> _resetarSenha(UsuarioModel usuario) async {
    final provider = context.read<UsuarioProvider>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reiniciar senha'),
          content: Text(
            'Deseja reiniciar a senha do usuário "${usuario.nome}" para 12345678?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    final sucesso = await provider.resetarSenha(usuario.idUsuario);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha reiniciada para 12345678.'),
        ),
      );
    } else {
      _mostrarErro(provider.erro ?? 'Não foi possível reiniciar a senha.');
    }
  }

  void _abrirDetalhes(UsuarioModel usuario) {
    Navigator.pushNamed(
      context,
      '/usuarios/detalhes',
      arguments: usuario,
    );
  }

  void _abrirCadastro() {
    Navigator.pushNamed(context, '/usuarios/form');
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Color _corPerfil(String? perfil) {
    final nome = perfil?.toLowerCase().trim() ?? '';

    if (nome.contains('gerente')) {
      return Colors.blue;
    }

    if (nome.contains('operador')) {
      return Colors.green;
    }

    if (nome.contains('vendedor')) {
      return Colors.teal;
    }

    if (nome.contains('cliente')) {
      return Colors.orange;
    }

    return Colors.blueGrey;
  }

  bool _isAdministrador(UsuarioModel usuario) {
    return usuario.nomePerfil?.toLowerCase().trim() == 'administrador';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text('Usuários'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => _aplicarFiltro(_filtro),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Novo usuário'),
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, provider, _) {
          final usuariosVisiveis = provider.usuarios
              .where((usuario) => !_isAdministrador(usuario))
              .toList();

          return Column(
            children: [
              _FiltrosUsuarios(
                filtroAtual: _filtro,
                onChanged: _aplicarFiltro,
              ),

              if (provider.erro != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    width: double.infinity,
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
                ),

              Expanded(
                child: provider.isLoading && usuariosVisiveis.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : usuariosVisiveis.isEmpty
                        ? const _EstadoVazioUsuarios()
                        : RefreshIndicator(
                            onRefresh: () => _aplicarFiltro(_filtro),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                              itemCount: usuariosVisiveis.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final usuario = usuariosVisiveis[index];
                                final perfilCor = _corPerfil(usuario.nomePerfil);

                                return Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  elevation: 1,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _abrirDetalhes(usuario),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                perfilCor.withOpacity(0.12),
                                            child: Text(
                                              usuario.nome.isNotEmpty
                                                  ? usuario.nome[0].toUpperCase()
                                                  : '?',
                                              style: TextStyle(
                                                color: perfilCor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        usuario.nome,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: theme.textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _StatusBadge(
                                                      ativo: usuario.ativo,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '@${usuario.username}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 6,
                                                  children: [
                                                    _PerfilBadge(
                                                      nomePerfil:
                                                          usuario.nomePerfil ??
                                                              'Sem perfil',
                                                      cor: perfilCor,
                                                    ),
                                                    if (usuario.criadoEm != null)
                                                      _InfoBadge(
                                                        icon: Icons
                                                            .calendar_today_rounded,
                                                        texto: _formatarData(
                                                          usuario.criadoEm!,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          Column(
                                            children: [
                                              Switch(
                                                value: usuario.ativo,
                                                onChanged: provider.isLoading
                                                    ? null
                                                    : (_) =>
                                                        _toggleAtivo(usuario),
                                              ),
                                              IconButton(
                                                tooltip: 'Reiniciar senha',
                                                onPressed: provider.isLoading
                                                    ? null
                                                    : () =>
                                                        _resetarSenha(usuario),
                                                icon: const Icon(
                                                  Icons.lock_reset_rounded,
                                                ),
                                              ),
                                            ],
                                          ),

                                          IconButton(
                                            tooltip: 'Ver detalhes',
                                            onPressed: () =>
                                                _abrirDetalhes(usuario),
                                            icon: const Icon(
                                              Icons.chevron_right_rounded,
                                              size: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }
}

class _FiltrosUsuarios extends StatelessWidget {
  final UsuarioFiltroStatus filtroAtual;
  final ValueChanged<UsuarioFiltroStatus> onChanged;

  const _FiltrosUsuarios({
    required this.filtroAtual,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FiltroChip(
            label: 'Todos',
            icon: Icons.people_alt_rounded,
            selected: filtroAtual == UsuarioFiltroStatus.todos,
            onTap: () => onChanged(UsuarioFiltroStatus.todos),
          ),
          const SizedBox(width: 10),
          _FiltroChip(
            label: 'Activos',
            icon: Icons.verified_user_rounded,
            selected: filtroAtual == UsuarioFiltroStatus.ativos,
            onTap: () => onChanged(UsuarioFiltroStatus.ativos),
          ),
          const SizedBox(width: 10),
          _FiltroChip(
            label: 'Inactivos',
            icon: Icons.person_off_rounded,
            selected: filtroAtual == UsuarioFiltroStatus.inativos,
            onTap: () => onChanged(UsuarioFiltroStatus.inativos),
          ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;

    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? Colors.white : selectedColor,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? Colors.white : selectedColor,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: selectedColor,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? selectedColor : Colors.grey.shade300,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool ativo;

  const _StatusBadge({
    required this.ativo,
  });

  @override
  Widget build(BuildContext context) {
    final color = ativo ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ativo ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: color.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PerfilBadge extends StatelessWidget {
  final String nomePerfil;
  final Color cor;

  const _PerfilBadge({
    required this.nomePerfil,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        nomePerfil,
        style: TextStyle(
          color: cor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _InfoBadge({
    required this.icon,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVazioUsuarios extends StatelessWidget {
  const _EstadoVazioUsuarios();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum usuário encontrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Crie um novo usuário ou altere os filtros de pesquisa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}