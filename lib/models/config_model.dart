class ConfigModel {
  final String uri;
  final String user;
  final String password;
  final String? token;

  ConfigModel({
    required this.uri,
    required this.user,
    required this.password,
    this.token,
  });

  ConfigModel copyWith({
    String? uri,
    String? user,
    String? password,
    String? token,
  }) {
    return ConfigModel(
      uri: uri ?? this.uri,
      user: user ?? this.user,
      password: password ?? this.password,
      token: token ?? this.token,
    );
  }

  // ------------------------------------------------------------
  // JSON → MODEL (con validazione)
  // ------------------------------------------------------------
  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    final uri = json['uri']?.toString() ?? '';
    final user = json['user']?.toString() ?? '';
    final password = json['password']?.toString() ?? '';
    final token = json['token']?.toString();

    // Se i campi obbligatori sono vuoti → config NON valida
    if (uri.isEmpty || user.isEmpty || password.isEmpty) {
      throw Exception("Invalid config");
    }

    return ConfigModel(
      uri: uri,
      user: user,
      password: password,
      token: token,
    );
  }

  // ------------------------------------------------------------
  // MODEL → JSON
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'user': user,
      'password': password,
      'token': token,
    };
  }
}

