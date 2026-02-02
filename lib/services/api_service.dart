import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/app_model.dart';
import '../models/config_model.dart';

class ApiService {
  Future<String?> login(ConfigModel config) async {
    final url = Uri.parse('${config.uri}/auth/login');

    print("🟡 [ApiService.login] URL: $url");
    print("🟡 [ApiService.login] BODY: { email: ${config.user}, password: ${config.password} }");

    final res = await http.post(
      url,
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({
        'email': config.user,
        'password': config.password,
      }),
    );

    print("🟡 [ApiService.login] STATUS: ${res.statusCode}");
    print("🟡 [ApiService.login] RESPONSE: ${res.body}");

    if (res.statusCode == 200) {
      try {
        final json = jsonDecode(res.body);
        print("🟢 [ApiService.login] TOKEN: ${json['token']}");
        return json['token'];
      } catch (e) {
        print("🔴 [ApiService.login] ERRORE PARSING TOKEN: $e");
        return null;
      }
    }

    print("🔴 [ApiService.login] Login fallito");
    return null;
  }

  Future<List<AppModel>> fetchApps(ConfigModel config, String token) async {
    final url = Uri.parse('${config.uri}/links');

    print("🟡 [ApiService.fetchApps] URL: $url");
    print("🟡 [ApiService.fetchApps] TOKEN: $token");

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("🟡 [ApiService.fetchApps] STATUS: ${res.statusCode}");
    print("🟡 [ApiService.fetchApps] RESPONSE: ${res.body}");

    if (res.statusCode != 200) {
      print("🔴 [ApiService.fetchApps] Errore nel caricamento app");
      return [];
    }

    try {
      final json = jsonDecode(res.body);

      if (json is! List) {
        print("🔴 [ApiService.fetchApps] JSON non è una lista");
        return [];
      }

      final apps = json.map<AppModel>((e) => AppModel.fromJson(e)).toList();
      print("🟢 [ApiService.fetchApps] App parse OK: ${apps.length} app trovate");

      return apps;
    } catch (e) {
      print("🔴 [ApiService.fetchApps] ERRORE PARSING APPS: $e");
      return [];
    }
  }
}
