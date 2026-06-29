import '../model/usuario_model.dart';
import '../service/usuario_service.dart';

class UsuarioRepository {
  final UsuarioService _service;

  UsuarioRepository({
    UsuarioService? service,
  }) : _service = service ?? UsuarioService();

  // ─────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────

  Future<LoginResponseModel> login({
    required String username,
    required String senha,
  }) async {
    final request = LoginRequestModel(
      username: username.trim(),
      senha: senha,
    );

    return _service.login(request);
  }

  // ─────────────────────────────────────────────────────────────
  // PERFIS
  //
  // Regra:
  // - Os perfis vêm da tabela perfil via GET /api/perfis.
  // - O perfil Administrador não deve aparecer no cadastro.
  // - O service já faz defesa extra, mas mantemos outra aqui.
  // ─────────────────────────────────────────────────────────────

  Future<List<PerfilUsuarioModel>> listarPerfis() async {
    final perfis = await _service.listarPerfis();

    return perfis
        .where((perfil) => !perfil.isAdministrador)
        .toList();
  }

  // ─────────────────────────────────────────────────────────────
  // LISTAGEM
  //
  // Regra:
  // - Administrador não deve aparecer na lista.
  // - O backend já filtra.
  // - O service também filtra.
  // - Aqui mantemos defesa extra para evitar fuga visual.
  // ─────────────────────────────────────────────────────────────

  Future<List<UsuarioModel>> listarTodos() async {
    final usuarios = await _service.listar();

    return _removerAdministradores(usuarios);
  }

  Future<List<UsuarioModel>> listarAtivos() async {
    final usuarios = await _service.listar(ativo: true);

    return _removerAdministradores(usuarios);
  }

  Future<List<UsuarioModel>> listarInativos() async {
    final usuarios = await _service.listar(ativo: false);

    return _removerAdministradores(usuarios);
  }

  Future<List<UsuarioModel>> listarPorStatus({bool? ativo}) async {
    final usuarios = await _service.listar(ativo: ativo);

    return _removerAdministradores(usuarios);
  }

  // ─────────────────────────────────────────────────────────────
  // BUSCA
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> buscarPorId(int idUsuario) async {
    final usuario = await _service.buscarPorId(idUsuario);

    if (_isAdministrador(usuario.nomePerfil)) {
      throw UsuarioRepositoryException(
        'Usuário administrador não pode ser exibido nesta área.',
      );
    }

    return usuario;
  }

  // ─────────────────────────────────────────────────────────────
  // CRIAÇÃO
  //
  // Regra:
  // - O formulário não mostra campo de senha.
  // - Enviamos senha null.
  // - O backend aplica a senha padrão 12345678.
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> criar({
    required String nome,
    required String username,
    int? idPerfil,
  }) async {
    final request = UsuarioRequestModel(
      nome: nome.trim(),
      username: username.trim(),
      senha: null,
      idPerfil: idPerfil,
    );

    return _service.criar(request);
  }

  // ─────────────────────────────────────────────────────────────
  // ACTUALIZAÇÃO
  //
  // Regra:
  // - O formulário não altera senha.
  // - Enviamos senha null.
  // - O backend mantém a senha actual.
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> atualizar({
    required int idUsuario,
    required String nome,
    required String username,
    int? idPerfil,
  }) async {
    final request = UsuarioRequestModel(
      nome: nome.trim(),
      username: username.trim(),
      senha: null,
      idPerfil: idPerfil,
    );

    return _service.atualizar(
      idUsuario: idUsuario,
      request: request,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ESTADO DO USUÁRIO
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> toggleAtivo(int idUsuario) async {
    final usuario = await _service.toggleAtivo(idUsuario);

    if (_isAdministrador(usuario.nomePerfil)) {
      throw UsuarioRepositoryException(
        'Usuário administrador não pode ser alterado nesta área.',
      );
    }

    return usuario;
  }

  Future<UsuarioModel> ativar(int idUsuario) async {
    final usuario = await _service.ativar(idUsuario);

    if (_isAdministrador(usuario.nomePerfil)) {
      throw UsuarioRepositoryException(
        'Usuário administrador não pode ser activado nesta área.',
      );
    }

    return usuario;
  }

  Future<UsuarioModel> desativar(int idUsuario) async {
    final usuario = await _service.desativar(idUsuario);

    if (_isAdministrador(usuario.nomePerfil)) {
      throw UsuarioRepositoryException(
        'Usuário administrador não pode ser desactivado nesta área.',
      );
    }

    return usuario;
  }

  // ─────────────────────────────────────────────────────────────
  // SENHA
  //
  // Regra:
  // - Reset pelo administrador operacional volta para 12345678.
  // - Alterar senha fica disponível para tela futura de conta própria.
  // ─────────────────────────────────────────────────────────────

  Future<String> resetarSenha(int idUsuario) async {
    return _service.resetarSenha(idUsuario);
  }

  Future<String> alterarSenha({
    required int idUsuario,
    required String senhaAtual,
    required String novaSenha,
  }) async {
    return _service.alterarSenha(
      idUsuario: idUsuario,
      senhaAtual: senhaAtual,
      novaSenha: novaSenha,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  List<UsuarioModel> _removerAdministradores(List<UsuarioModel> usuarios) {
    return usuarios
        .where((usuario) => !_isAdministrador(usuario.nomePerfil))
        .toList();
  }

  bool _isAdministrador(String? nomePerfil) {
    return nomePerfil?.toLowerCase().trim() == 'administrador';
  }
}

class UsuarioRepositoryException implements Exception {
  final String message;

  UsuarioRepositoryException(this.message);

  @override
  String toString() => message;
}