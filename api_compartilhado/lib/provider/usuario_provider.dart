import 'package:flutter/foundation.dart';

import '../model/usuario_model.dart';
import '../repository/usuario_repository.dart';

class UsuarioProvider extends ChangeNotifier {
  final UsuarioRepository _repository;

  UsuarioProvider({
    UsuarioRepository? repository,
  }) : _repository = repository ?? UsuarioRepository();

  // ─────────────────────────────────────────────────────────────
  // ESTADO GERAL
  // ─────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _erro;

  List<UsuarioModel> _usuarios = [];
  List<PerfilUsuarioModel> _perfis = [];

  UsuarioModel? _usuarioSelecionado;
  UsuarioModel? _usuarioLogado;
  String? _token;

  bool get isLoading => _isLoading;
  String? get erro => _erro;

  List<UsuarioModel> get usuarios => List.unmodifiable(_usuarios);
  List<PerfilUsuarioModel> get perfis => List.unmodifiable(_perfis);

  UsuarioModel? get usuarioSelecionado => _usuarioSelecionado;
  UsuarioModel? get usuarioLogado => _usuarioLogado;
  String? get token => _token;

  bool get temUsuarioLogado => _usuarioLogado != null;

  bool get temPerfis => _perfis.isNotEmpty;
  bool get temUsuarios => _usuarios.isNotEmpty;

  // ─────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────

  Future<bool> login({
    required String username,
    required String senha,
  }) async {
    _setLoading(true);
    _limparErro();

    try {
      final response = await _repository.login(
        username: username,
        senha: senha,
      );

      _usuarioLogado = response.usuario;
      _token = response.token;

      notifyListeners();
      return true;
    } catch (e) {
      _setErro(_normalizarErro(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _usuarioLogado = null;
    _token = null;
    _usuarioSelecionado = null;

    _limparErro();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // PERFIS
  //
  // Regra:
  // - Perfis vêm da tabela perfil via GET /api/perfis.
  // - Administrador não deve aparecer no cadastro.
  // - Repository/Service já filtram, mas mantemos defesa aqui.
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarPerfis() async {
    _setLoading(true);
    _limparErro();

    try {
      final perfisApi = await _repository.listarPerfis();

      _perfis = perfisApi
          .where((perfil) => !perfil.isAdministrador)
          .toList();

      notifyListeners();
    } catch (e) {
      _setErro(_normalizarErro(e));
    } finally {
      _setLoading(false);
    }
  }

  void limparPerfis() {
    _perfis = [];
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // LISTAGEM DE USUÁRIOS
  //
  // Regra:
  // - Administrador não aparece na lista.
  // - Backend já filtra.
  // - Repository/Service também filtram.
  // - Provider mantém defesa final.
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarUsuarios({bool? ativo}) async {
    _setLoading(true);
    _limparErro();

    try {
      final usuariosApi = await _repository.listarPorStatus(ativo: ativo);

      _usuarios = _removerAdministradores(usuariosApi);

      notifyListeners();
    } catch (e) {
      _setErro(_normalizarErro(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> carregarTodos() async {
    await carregarUsuarios();
  }

  Future<void> carregarAtivos() async {
    await carregarUsuarios(ativo: true);
  }

  Future<void> carregarInativos() async {
    await carregarUsuarios(ativo: false);
  }

  // ─────────────────────────────────────────────────────────────
  // BUSCA
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel?> buscarPorId(int idUsuario) async {
    _setLoading(true);
    _limparErro();

    try {
      final usuario = await _repository.buscarPorId(idUsuario);

      if (_isAdministrador(usuario.nomePerfil)) {
        _setErro('Usuário administrador não pode ser exibido nesta área.');
        return null;
      }

      _usuarioSelecionado = usuario;

      notifyListeners();
      return usuario;
    } catch (e) {
      _setErro(_normalizarErro(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void selecionarUsuario(UsuarioModel? usuario) {
    if (usuario != null && _isAdministrador(usuario.nomePerfil)) {
      _setErro('Usuário administrador não pode ser seleccionado nesta área.');
      return;
    }

    _usuarioSelecionado = usuario;
    notifyListeners();
  }

  void limparSelecionado() {
    _usuarioSelecionado = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // CRIAR USUÁRIO
  //
  // Regra:
  // - O formulário não tem campo senha.
  // - A senha não é enviada pelo frontend.
  // - Backend aplica senha padrão 12345678.
  // ─────────────────────────────────────────────────────────────

  Future<bool> criarUsuario({
    required String nome,
    required String username,
    int? idPerfil,
  }) async {
    _setLoading(true);
    _limparErro();

    try {
      final criado = await _repository.criar(
        nome: nome,
        username: username,
        idPerfil: idPerfil,
      );

      if (!_isAdministrador(criado.nomePerfil)) {
        _usuarios = [criado, ..._usuarios];
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setErro(_normalizarErro(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ACTUALIZAR USUÁRIO
  //
  // Regra:
  // - O formulário não altera senha.
  // - Backend mantém a senha actual.
  // ─────────────────────────────────────────────────────────────

  Future<bool> atualizarUsuario({
    required int idUsuario,
    required String nome,
    required String username,
    int? idPerfil,
  }) async {
    _setLoading(true);
    _limparErro();

    try {
      final atualizado = await _repository.atualizar(
        idUsuario: idUsuario,
        nome: nome,
        username: username,
        idPerfil: idPerfil,
      );

      if (_isAdministrador(atualizado.nomePerfil)) {
        _removerDaLista(idUsuario);
      } else {
        _substituirNaLista(atualizado);
      }

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = _isAdministrador(atualizado.nomePerfil)
            ? null
            : atualizado;
      }

      if (_usuarioLogado?.idUsuario == idUsuario) {
        _usuarioLogado = atualizado;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setErro(_normalizarErro(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ACTIVAR / DESACTIVAR
  // ─────────────────────────────────────────────────────────────

  Future<bool> toggleAtivo(int idUsuario) async {
    _setLoading(true);
    _limparErro();

    try {
      final atualizado = await _repository.toggleAtivo(idUsuario);

      if (_isAdministrador(atualizado.nomePerfil)) {
        _removerDaLista(idUsuario);
        _setErro('Usuário administrador não pode ser alterado nesta área.');
        return false;
      }

      _substituirNaLista(atualizado);

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = atualizado;
      }

      if (_usuarioLogado?.idUsuario == idUsuario) {
        _usuarioLogado = atualizado;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setErro(_normalizarErro(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> ativarUsuario(int idUsuario) async {
    _setLoading(true);
    _limparErro();

    try {
      final atualizado = await _repository.ativar(idUsuario);

      if (_isAdministrador(atualizado.nomePerfil)) {
        _removerDaLista(idUsuario);
        _setErro('Usuário administrador não pode ser activado nesta área.');
        return false;
      }

      _substituirNaLista(atualizado);

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = atualizado;
      }

      if (_usuarioLogado?.idUsuario == idUsuario) {
        _usuarioLogado = atualizado;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setErro(_normalizarErro(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> desativarUsuario(int idUsuario) async {
    _setLoading(true);
    _limparErro();

    try {
      final atualizado = await _repository.desativar(idUsuario);

      if (_isAdministrador(atualizado.nomePerfil)) {
        _removerDaLista(idUsuario);
        _setErro('Usuário administrador não pode ser desactivado nesta área.');
        return false;
      }

      _substituirNaLista(atualizado);

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = atualizado;
      }

      if (_usuarioLogado?.idUsuario == idUsuario) {
        _usuarioLogado = atualizado;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setErro(_normalizarErro(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // SENHAS
  // ─────────────────────────────────────────────────────────────

  Future<bool> resetarSenha(int idUsuario) async {
    _setLoading(true);
    _limparErro();

    try {
      await _repository.resetarSenha(idUsuario);
      return true;
    } catch (e) {
      _setErro(_normalizarErro(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> alterarSenha({
    required int idUsuario,
    required String senhaAtual,
    required String novaSenha,
  }) async {
    _setLoading(true);
    _limparErro();

    try {
      await _repository.alterarSenha(
        idUsuario: idUsuario,
        senhaAtual: senhaAtual,
        novaSenha: novaSenha,
      );

      return true;
    } catch (e) {
      _setErro(_normalizarErro(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS DE ESTADO
  // ─────────────────────────────────────────────────────────────

  void limparErro() {
    _limparErro();
    notifyListeners();
  }

  void limparEstado() {
    _isLoading = false;
    _erro = null;
    _usuarios = [];
    _perfis = [];
    _usuarioSelecionado = null;

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErro(String mensagem) {
    _erro = mensagem;
    notifyListeners();
  }

  void _limparErro() {
    _erro = null;
  }

  void _substituirNaLista(UsuarioModel usuario) {
    final index = _usuarios.indexWhere(
      (u) => u.idUsuario == usuario.idUsuario,
    );

    if (index >= 0) {
      final novaLista = [..._usuarios];
      novaLista[index] = usuario;
      _usuarios = novaLista;
    } else {
      _usuarios = [usuario, ..._usuarios];
    }

    _usuarios = _removerAdministradores(_usuarios);
  }

  void _removerDaLista(int idUsuario) {
    _usuarios = _usuarios
        .where((usuario) => usuario.idUsuario != idUsuario)
        .toList();
  }

  List<UsuarioModel> _removerAdministradores(List<UsuarioModel> usuarios) {
    return usuarios
        .where((usuario) => !_isAdministrador(usuario.nomePerfil))
        .toList();
  }

  bool _isAdministrador(String? nomePerfil) {
    return nomePerfil?.toLowerCase().trim() == 'administrador';
  }

  String _normalizarErro(Object erro) {
    final texto = erro.toString();

    if (texto.startsWith('Exception: ')) {
      return texto.replaceFirst('Exception: ', '');
    }

    return texto;
  }
}