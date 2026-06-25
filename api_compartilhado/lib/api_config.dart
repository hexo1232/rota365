class ApiConfig {
  ApiConfig._();

  /*
   * URL base da API Rota365.
   *
   * Em debug, podes trocar para localhost, Render, Railway, VPS, etc.
   * Em release, podes compilar usando:
   *
   * flutter build windows --dart-define=API_BASE_URL=https://api.rota365.co.mz
   */
  static const String _defaultBaseUrl = 'http://localhost:8080';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  // ─────────────────────────────────────────────────────────────
  // AUTH
  // Backend:
  // POST /api/auth/login
  // ─────────────────────────────────────────────────────────────

  static String get loginUrl => '$baseUrl/api/auth/login';

  // ─────────────────────────────────────────────────────────────
  // USUÁRIOS
  // Backend:
  // GET    /api/usuarios
  // GET    /api/usuarios/{idUsuario}
  // POST   /api/usuarios
  // PUT    /api/usuarios/{idUsuario}
  // PATCH  /api/usuarios/{idUsuario}/toggle-ativo
  // PATCH  /api/usuarios/{idUsuario}/ativar
  // PATCH  /api/usuarios/{idUsuario}/desativar
  // POST   /api/usuarios/{idUsuario}/reset-senha
  // PATCH  /api/usuarios/{idUsuario}/alterar-senha
  // ─────────────────────────────────────────────────────────────

  static String get usuariosUrl => '$baseUrl/api/usuarios';

  static String usuarioPorIdUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario';
  }

  static String usuariosPorStatusUrl({bool? ativo}) {
    if (ativo == null) return usuariosUrl;
    return '$usuariosUrl?ativo=$ativo';
  }

  static String toggleAtivoUsuarioUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario/toggle-ativo';
  }

  static String ativarUsuarioUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario/ativar';
  }

  static String desativarUsuarioUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario/desativar';
  }

  static String resetSenhaUsuarioUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario/reset-senha';
  }

  static String alterarSenhaUsuarioUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario/alterar-senha';
  }
}