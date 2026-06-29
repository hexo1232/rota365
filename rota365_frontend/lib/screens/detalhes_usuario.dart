import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

import 'package:api_compartilhado/api_compartilhado.dart';

class DetalhesUsuarioScreen extends StatefulWidget {
  const DetalhesUsuarioScreen({super.key});

  @override
  State<DetalhesUsuarioScreen> createState() => _DetalhesUsuarioScreenState();
}

class _DetalhesUsuarioScreenState extends State<DetalhesUsuarioScreen> {
  UsuarioModel? _usuarioInicial;
  bool _carregouArgumentos = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_carregouArgumentos) return;
    _carregouArgumentos = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is UsuarioModel) {
      _usuarioInicial = args;
      context.read<UsuarioProvider>().selecionarUsuario(args);
      return;
    }

    if (args is int) {
      Future.microtask(() {
        context.read<UsuarioProvider>().buscarPorId(args);
      });
    }
  }

  Future<void> _atualizarUsuario(UsuarioModel usuario) async {
    await context.read<UsuarioProvider>().buscarPorId(usuario.idUsuario);
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

  void _abrirEdicao(UsuarioModel usuario) {
    Navigator.pushNamed(
      context,
      '/usuarios/form',
      arguments: usuario,
    );
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
    final nome = perfil?.toLowerCase() ?? '';

    if (nome.contains('admin')) return Colors.deepPurple;
    if (nome.contains('gerente')) return Colors.blue;
    if (nome.contains('operador') || nome.contains('vendedor')) return Colors.green;

    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsuarioProvider>(
      builder: (context, provider, _) {
        final usuario = provider.usuarioSelecionado ?? _usuarioInicial;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F5F7),
          appBar: AppBar(
            title: const Text('Detalhes do usuário'),
            actions: [
              if (usuario != null)
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: provider.isLoading
                      ? null
                      : () => _atualizarUsuario(usuario),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              if (usuario != null)
                IconButton(
                  tooltip: 'Editar',
                  onPressed: () => _abrirEdicao(usuario),
                  icon: const Icon(Icons.edit_rounded),
                ),
            ],
          ),
          body: _buildBody(context, provider, usuario),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    UsuarioProvider provider,
    UsuarioModel? usuario,
  ) {
    if (provider.isLoading && usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (usuario == null) {
      return const _UsuarioNaoEncontrado();
    }

    final perfilCor = _corPerfil(usuario.nomePerfil);

    return RefreshIndicator(
      onRefresh: () => _atualizarUsuario(usuario),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _HeaderUsuario(
            usuario: usuario,
            perfilCor: perfilCor,
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

          _SecaoDetalhes(
            titulo: 'Informações principais',
            icon: Icons.person_rounded,
            children: [
              _LinhaDetalhe(
                icon: Icons.badge_rounded,
                label: 'ID do usuário',
                value: usuario.idUsuario.toString(),
              ),
              _LinhaDetalhe(
                icon: Icons.person_outline_rounded,
                label: 'Nome',
                value: usuario.nome,
              ),
              _LinhaDetalhe(
                icon: Icons.alternate_email_rounded,
                label: 'Username',
                value: '@${usuario.username}',
              ),
              _LinhaDetalhe(
                icon: Icons.verified_user_rounded,
                label: 'Estado',
                value: usuario.ativo ? 'Activo' : 'Inactivo',
                valueColor: usuario.ativo ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ],
          ),

          const SizedBox(height: 14),

          _SecaoDetalhes(
            titulo: 'Perfil e permissões',
            icon: Icons.admin_panel_settings_rounded,
            children: [
              _LinhaDetalhe(
                icon: Icons.key_rounded,
                label: 'ID do perfil',
                value: usuario.idPerfil?.toString() ?? '-',
              ),
              _LinhaDetalhe(
                icon: Icons.shield_rounded,
                label: 'Nome do perfil',
                value: usuario.nomePerfil ?? 'Sem perfil',
                valueColor: perfilCor,
              ),
            ],
          ),

          const SizedBox(height: 14),

          _SecaoDetalhes(
            titulo: 'Auditoria',
            icon: Icons.history_rounded,
            children: [
              _LinhaDetalhe(
                icon: Icons.calendar_today_rounded,
                label: 'Criado em',
                value: usuario.criadoEm != null
                    ? _formatarDataHora(usuario.criadoEm!)
                    : '-',
              ),
            ],
          ),

          const SizedBox(height: 20),

          _AcoesUsuario(
            usuario: usuario,
            isLoading: provider.isLoading,
            onToggleAtivo: () => _toggleAtivo(usuario),
            onResetSenha: () => _resetarSenha(usuario),
            onEditar: () => _abrirEdicao(usuario),
          ),
        ],
      ),
    );
  }

  String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano às $hora:$minuto';
  }
}

class _HeaderUsuario extends StatelessWidget {
  final UsuarioModel usuario;
  final Color perfilCor;

  const _HeaderUsuario({
    required this.usuario,
    required this.perfilCor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inicial = usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: perfilCor.withValues(alpha: 0.12),
            child: Text(
              inicial,
              style: TextStyle(
                color: perfilCor,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${usuario.username}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniBadge(
                      texto: usuario.nomePerfil ?? 'Sem perfil',
                      icon: Icons.shield_rounded,
                      color: perfilCor,
                    ),
                    _MiniBadge(
                      texto: usuario.ativo ? 'Activo' : 'Inactivo',
                      icon: usuario.ativo
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: usuario.ativo ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecaoDetalhes extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final List<Widget> children;

  const _SecaoDetalhes({
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
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
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LinhaDetalhe extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _LinhaDetalhe({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.grey.shade900,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String texto;
  final IconData icon;
  final Color color;

  const _MiniBadge({
    required this.texto,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcoesUsuario extends StatelessWidget {
  final UsuarioModel usuario;
  final bool isLoading;
  final VoidCallback onToggleAtivo;
  final VoidCallback onResetSenha;
  final VoidCallback onEditar;

  const _AcoesUsuario({
    required this.usuario,
    required this.isLoading,
    required this.onToggleAtivo,
    required this.onResetSenha,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isLoading ? null : onEditar,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Editar usuário'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onToggleAtivo,
            icon: Icon(
              usuario.ativo
                  ? Icons.person_off_rounded
                  : Icons.person_add_alt_1_rounded,
            ),
            label: Text(usuario.ativo ? 'Desactivar usuário' : 'Activar usuário'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onResetSenha,
            icon: const Icon(Icons.lock_reset_rounded),
            label: const Text('Reiniciar senha para 12345678'),
          ),
        ),
      ],
    );
  }
}

class _UsuarioNaoEncontrado extends StatelessWidget {
  const _UsuarioNaoEncontrado();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Usuário não encontrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Volte à lista de usuários e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}