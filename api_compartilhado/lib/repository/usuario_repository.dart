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
      username: username,
      senha: senha,
    );

    return _service.login(request);
  }

  // ─────────────────────────────────────────────────────────────
  // LISTAGEM
  // ─────────────────────────────────────────────────────────────

  Future<List<UsuarioModel>> listarTodos() async {
    return _service.listar();
  }

  Future<List<UsuarioModel>> listarAtivos() async {
    return _service.listar(ativo: true);
  }

  Future<List<UsuarioModel>> listarInativos() async {
    return _service.listar(ativo: false);
  }

  Future<List<UsuarioModel>> listarPorStatus({bool? ativo}) async {
    return _service.listar(ativo: ativo);
  }

  // ─────────────────────────────────────────────────────────────
  // BUSCA
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> buscarPorId(int idUsuario) async {
    return _service.buscarPorId(idUsuario);
  }

  // ─────────────────────────────────────────────────────────────
  // CRIAÇÃO
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> criar({
    required String nome,
    required String username,
    String? senha,
    int? idPerfil,
  }) async {
    final request = UsuarioRequestModel(
      nome: nome,
      username: username,
      senha: _normalizarSenha(senha),
      idPerfil: idPerfil,
    );

    return _service.criar(request);
  }

  // ─────────────────────────────────────────────────────────────
  // ACTUALIZAÇÃO
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> atualizar({
    required int idUsuario,
    required String nome,
    required String username,
    String? senha,
    int? idPerfil,
  }) async {
    final request = UsuarioRequestModel(
      nome: nome,
      username: username,
      senha: _normalizarSenha(senha),
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
    return _service.toggleAtivo(idUsuario);
  }

  Future<UsuarioModel> ativar(int idUsuario) async {
    return _service.ativar(idUsuario);
  }

  Future<UsuarioModel> desativar(int idUsuario) async {
    return _service.desativar(idUsuario);
  }

  // ─────────────────────────────────────────────────────────────
  // SENHA
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

  String? _normalizarSenha(String? senha) {
    if (senha == null) return null;

    final limpa = senha.trim();

    if (limpa.isEmpty) return null;

    return limpa;
  }
}