import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/app_model.dart';
import '../models/config_model.dart';

class ApiService {
  Future<String?> login(ConfigModel config) async {
    final url = Uri.parse('${config.uri}/auth/login');

    final res = await http.post(
      url,
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({
        'email': config.user,
        'password': config.password,
      }),
    );

    print('LOGIN STATUS: ${res.statusCode}');
    print('LOGIN BODY: ${res.body}');

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['token'];
    }

    return null;
  }

  Future<List<AppModel>> fetchApps(ConfigModel config, String token) async {
    final url = Uri.parse('${config.uri}/links');

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('APPS STATUS: ${res.statusCode}');
    print('APPS BODY: ${res.body}');

    if (res.statusCode != 200) return [];

    final json = jsonDecode(res.body);

    if (json is! List) return [];

    return json.map<AppModel>((e) => AppModel.fromJson(e)).toList();
  }
}

