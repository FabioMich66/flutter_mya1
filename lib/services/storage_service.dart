import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as enc;

import '../models/app_model.dart';
import '../models/config_model.dart';

class StorageService {
  static const _secretKey = 'chiave-super-segreta-123';
  static const _configKey = 'launcherConfig';
  static const _appsKey = 'jsonApps';
  static const _orderKey = 'appsOrder';
  static const _zoomKey = 'zoomLevel';

  enc.Encrypter get _encrypter {
    final key = enc.Key.fromUtf8(_secretKey.padRight(32).substring(0, 32));
    final iv = enc.IV.fromLength(16);
    return enc.Encrypter(enc.AES(key));
  }

  // ------------------------------------------------------------
  // CONFIG
  // ------------------------------------------------------------

  Future<void> saveConfig(ConfigModel config) async {
    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(config.toJson());
    final encrypted = _encrypter.encrypt(
      json,
      iv: enc.IV.fromLength(16),
    ).base64;

    await prefs.setString(_configKey, encrypted);

    // 🔍 DEBUG (se vuoi)
    // print("SAVE CONFIG JSON: $json");
    // print("SAVE CONFIG ENCRYPTED: $encrypted");
  }

  Future<ConfigModel?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_configKey);

    if (encrypted == null) {
      // print("LOAD CONFIG: nessuna config salvata");
      return null;
    }

    try {
      final decrypted = _encrypter.decrypt(
        enc.Encrypted.fromBase64(encrypted),
        iv: enc.IV.fromLength(16),
      );

      // 🔍 DEBUG (se vuoi)
      // print("LOAD CONFIG ENCRYPTED: $encrypted");
      // print("LOAD CONFIG DECRYPTED: $decrypted");

      return ConfigModel.fromJson(jsonDecode(decrypted));
    } catch (e) {
      // print("ERRORE loadConfig(): $e");
      return null;
    }
  }

  // ------------------------------------------------------------
  // APPS
  // ------------------------------------------------------------

  Future<void> saveApps(List<AppModel> apps) async {
    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(apps.map((a) => a.toJson()).toList());
    final encrypted = _encrypter.encrypt(
      json,
      iv: enc.IV.fromLength(16),
    ).base64;

    await prefs.setString(_appsKey, encrypted);

    // 🔍 DEBUG
    // print("SAVE APPS JSON: $json");
  }

  Future<List<AppModel>?> loadApps() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_appsKey);

    if (encrypted == null) return null;

    try {
      final decrypted = _encrypter.decrypt(
        enc.Encrypted.fromBase64(encrypted),
        iv: enc.IV.fromLength(16),
      );

      final list = jsonDecode(decrypted) as List;

      return list.map((e) => AppModel.fromJson(e)).toList();
    } catch (e) {
      // print("ERRORE loadApps(): $e");
      return null;
    }
  }

  // ------------------------------------------------------------
  // ORDER
  // ------------------------------------------------------------

  Future<void> saveOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_orderKey, jsonEncode(order));
  }

  Future<List<String>?> loadOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_orderKey);

    if (raw == null) return null;

    try {
      return List<String>.from(jsonDecode(raw));
    } catch (e) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // ZOOM
  // ------------------------------------------------------------

  Future<void> saveZoom(double zoom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_zoomKey, zoom);
  }

  Future<double?> loadZoom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_zoomKey);
  }

  // ------------------------------------------------------------
  // RESET TOTALE
  // ------------------------------------------------------------

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configKey);
    await prefs.remove(_appsKey);
    await prefs.remove(_orderKey);
    await prefs.remove(_zoomKey);
  }
}
