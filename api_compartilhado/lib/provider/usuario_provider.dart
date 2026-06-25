import 'package:flutter/foundation.dart';

import '../model/usuario_model.dart';
import '../repository/usuario_repository.dart';

class UsuarioProvider extends ChangeNotifier {
  final UsuarioRepository _repository;

  UsuarioProvider({
    UsuarioRepository? repository,
  }) : _repository = repository ?? UsuarioRepository();

  // ─────────────────────────────────────────────────────────────
  // ESTADO
  // ─────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _erro;

  List<UsuarioModel> _usuarios = [];
  UsuarioModel? _usuarioSelecionado;
  UsuarioModel? _usuarioLogado;
  String? _token;

  bool get isLoading => _isLoading;
  String? get erro => _erro;

  List<UsuarioModel> get usuarios => List.unmodifiable(_usuarios);
  UsuarioModel? get usuarioSelecionado => _usuarioSelecionado;
  UsuarioModel? get usuarioLogado => _usuarioLogado;
  String? get token => _token;

  bool get temUsuarioLogado => _usuarioLogado != null;

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
  // LISTAGEM
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarUsuarios({bool? ativo}) async {
    _setLoading(true);
    _limparErro();

    try {
      _usuarios = await _repository.listarPorStatus(ativo: ativo);
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
    _usuarioSelecionado = usuario;
    notifyListeners();
  }

  void limparSelecionado() {
    _usuarioSelecionado = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // CRIAR
  // ─────────────────────────────────────────────────────────────

  Future<bool> criarUsuario({
    required String nome,
    required String username,
    String? senha,
    int? idPerfil,
  }) async {
    _setLoading(true);
    _limparErro();

    try {
      final criado = await _repository.criar(
        nome: nome,
        username: username,
        senha: senha,
        idPerfil: idPerfil,
      );

      _usuarios = [criado, ..._usuarios];

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
  // ACTUALIZAR
  // ─────────────────────────────────────────────────────────────

  Future<bool> atualizarUsuario({
    required int idUsuario,
    required String nome,
    required String username,
    String? senha,
    int? idPerfil,
  }) async {
    _setLoading(true);
    _limparErro();

    try {
      final atualizado = await _repository.atualizar(
        idUsuario: idUsuario,
        nome: nome,
        username: username,
        senha: senha,
        idPerfil: idPerfil,
      );

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
  // ACTIVAR / DESACTIVAR
  // ─────────────────────────────────────────────────────────────

  Future<bool> toggleAtivo(int idUsuario) async {
    _setLoading(true);
    _limparErro();

    try {
      final atualizado = await _repository.toggleAtivo(idUsuario);
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
      _substituirNaLista(atualizado);

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = atualizado;
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
  }

  String _normalizarErro(Object erro) {
    final texto = erro.toString();

    if (texto.startsWith('Exception: ')) {
      return texto.replaceFirst('Exception: ', '');
    }

    return texto;
  }
}