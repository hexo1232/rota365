class UsuarioModel {
  final int idUsuario;
  final String nome;
  final String username;
  final bool ativo;
  final int? idPerfil;
  final String? nomePerfil;
  final DateTime? criadoEm;

  const UsuarioModel({
    required this.idUsuario,
    required this.nome,
    required this.username,
    required this.ativo,
    this.idPerfil,
    this.nomePerfil,
    this.criadoEm,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: _parseInt(json['idUsuario']) ?? 0,
      nome: json['nome']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      ativo: _parseBool(json['ativo']),
      idPerfil: _parseInt(json['idPerfil']),
      nomePerfil: json['nomePerfil']?.toString(),
      criadoEm: _parseDateTime(json['criadoEm']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nome': nome,
      'username': username,
      'ativo': ativo,
      'idPerfil': idPerfil,
      'nomePerfil': nomePerfil,
      'criadoEm': criadoEm?.toIso8601String(),
    };
  }

  UsuarioModel copyWith({
    int? idUsuario,
    String? nome,
    String? username,
    bool? ativo,
    int? idPerfil,
    String? nomePerfil,
    DateTime? criadoEm,
  }) {
    return UsuarioModel(
      idUsuario: idUsuario ?? this.idUsuario,
      nome: nome ?? this.nome,
      username: username ?? this.username,
      ativo: ativo ?? this.ativo,
      idPerfil: idPerfil ?? this.idPerfil,
      nomePerfil: nomePerfil ?? this.nomePerfil,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is int) {
      return value == 1;
    }

    final text = value.toString().toLowerCase().trim();

    return text == 'true' || text == '1' || text == 'sim';
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}

class UsuarioRequestModel {
  final String nome;
  final String username;
  final String? senha;
  final int? idPerfil;

  const UsuarioRequestModel({
    required this.nome,
    required this.username,
    this.senha,
    this.idPerfil,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'username': username,
      'senha': senha,
      'idPerfil': idPerfil,
    };
  }
}

class LoginRequestModel {
  final String username;
  final String senha;

  const LoginRequestModel({
    required this.username,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'senha': senha,
    };
  }
}

class LoginResponseModel {
  final UsuarioModel usuario;
  final String? token;

  const LoginResponseModel({
    required this.usuario,
    this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      usuario: UsuarioModel.fromJson(
        Map<String, dynamic>.from(json['usuario'] as Map),
      ),
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario.toJson(),
      'token': token,
    };
  }
}