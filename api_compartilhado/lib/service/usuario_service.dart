import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../model/usuario_model.dart';

class UsuarioService {
  final http.Client _client;

  UsuarioService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  // ─────────────────────────────────────────────────────────────
  // AUTH
  // POST /api/auth/login
  // ─────────────────────────────────────────────────────────────

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _client
        .post(
          Uri.parse(ApiConfig.loginUrl),
          headers: _headers(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(body);
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Falha ao efectuar login.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LISTAR USUÁRIOS
  // GET /api/usuarios
  // GET /api/usuarios?ativo=true
  // GET /api/usuarios?ativo=false
  // ─────────────────────────────────────────────────────────────

  Future<List<UsuarioModel>> listar({bool? ativo}) async {
    final response = await _client
        .get(
          Uri.parse(ApiConfig.usuariosPorStatusUrl(ativo: ativo)),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      final list = body as List<dynamic>;

      return list
          .map(
            (item) => UsuarioModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Falha ao listar usuários.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BUSCAR POR ID
  // GET /api/usuarios/{idUsuario}
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> buscarPorId(int idUsuario) async {
    final response = await _client
        .get(
          Uri.parse(ApiConfig.usuarioPorIdUrl(idUsuario)),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return UsuarioModel.fromJson(
        Map<String, dynamic>.from(body as Map),
      );
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Usuário não encontrado.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CRIAR
  // POST /api/usuarios
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> criar(UsuarioRequestModel request) async {
    final response = await _client
        .post(
          Uri.parse(ApiConfig.usuariosUrl),
          headers: _headers(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 201) {
      return UsuarioModel.fromJson(
        Map<String, dynamic>.from(body as Map),
      );
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Falha ao criar usuário.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ATUALIZAR
  // PUT /api/usuarios/{idUsuario}
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> atualizar({
    required int idUsuario,
    required UsuarioRequestModel request,
  }) async {
    final response = await _client
        .put(
          Uri.parse(ApiConfig.usuarioPorIdUrl(idUsuario)),
          headers: _headers(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return UsuarioModel.fromJson(
        Map<String, dynamic>.from(body as Map),
      );
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Falha ao actualizar usuário.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOGGLE ATIVO
  // PATCH /api/usuarios/{idUsuario}/toggle-ativo
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> toggleAtivo(int idUsuario) async {
    final response = await _client
        .patch(
          Uri.parse(ApiConfig.toggleAtivoUsuarioUrl(idUsuario)),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return UsuarioModel.fromJson(
        Map<String, dynamic>.from(body as Map),
      );
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Falha ao alterar estado do usuário.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ATIVAR
  // PATCH /api/usuarios/{idUsuario}/ativar
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> ativar(int idUsuario) async {
    final response = await _client
        .patch(
          Uri.parse(ApiConfig.ativarUsuarioUrl(idUsuario)),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return UsuarioModel.fromJson(
        Map<String, dynamic>.from(body as Map),
      );
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Falha ao activar usuário.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // DESATIVAR
  // PATCH /api/usuarios/{idUsuario}/desativar
  // ─────────────────────────────────────────────────────────────

  Future<UsuarioModel> desativar(int idUsuario) async {
    final response = await _client
        .patch(
          Uri.parse(ApiConfig.desativarUsuarioUrl(idUsuario)),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return UsuarioModel.fromJson(
        Map<String, dynamic>.from(body as Map),
      );
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Falha ao desactivar usuário.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // RESETAR SENHA
  // POST /api/usuarios/{idUsuario}/reset-senha
  // ─────────────────────────────────────────────────────────────

  Future<String> resetarSenha(int idUsuario) async {
    final response = await _client
        .post(
          Uri.parse(ApiConfig.resetSenhaUsuarioUrl(idUsuario)),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return _extractErrorMessage(
        body,
        fallback: 'Senha redefinida com sucesso.',
      );
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Falha ao redefinir senha.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ALTERAR SENHA
  // PATCH /api/usuarios/{idUsuario}/alterar-senha
  // ─────────────────────────────────────────────────────────────

  Future<String> alterarSenha({
    required int idUsuario,
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final response = await _client
        .patch(
          Uri.parse(ApiConfig.alterarSenhaUsuarioUrl(idUsuario)),
          headers: _headers(),
          body: jsonEncode({
            'senhaAtual': senhaAtual,
            'novaSenha': novaSenha,
          }),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return _extractErrorMessage(
        body,
        fallback: 'Senha alterada com sucesso.',
      );
    }

    throw UsuarioServiceException(
      _extractErrorMessage(
        body,
        fallback: 'Falha ao alterar senha.',
      ),
      statusCode: response.statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return {
        'mensagem': response.body,
      };
    }
  }

  String _extractErrorMessage(
    dynamic body, {
    required String fallback,
  }) {
    if (body is Map) {
      final mensagem = body['mensagem'] ??
          body['message'] ??
          body['erro'] ??
          body['error'];

      if (mensagem != null && mensagem.toString().trim().isNotEmpty) {
        return mensagem.toString();
      }
    }

    if (body is String && body.trim().isNotEmpty) {
      return body;
    }

    return fallback;
  }
}

class UsuarioServiceException implements Exception {
  final String message;
  final int? statusCode;

  UsuarioServiceException(
    this.message, {
    this.statusCode,
  });

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }

    return 'HTTP $statusCode: $message';
  }
}