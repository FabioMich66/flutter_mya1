import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as enc;

import '../models/app_model.dart';
import '../models/config_model.dart';

class StorageService {
  // 🔐 Chiave AES-256 ESATTAMENTE di 32 caratteri
  static const _secretKey = 'my-super-secret-key-32bytes!!';

  static const _configKey = 'launcherConfig';
  static const _appsKey = 'jsonApps';
  static const _orderKey = 'appsOrder';
  static const _zoomKey = 'zoomLevel';

  enc.Encrypter get _encrypter {
    // 🔐 Usa la chiave così com’è (32 byte esatti)
    final key = enc.Key.fromUtf8(_secretKey);

    // 🔐 IV fisso di 16 byte (tutti zero)
    final iv = enc.IV.fromLength(16);

    return enc.Encrypter(enc.AES(key));
  }

  // ------------------------------------------------------------
  // CONFIG
  // ------------------------------------------------------------

  Future<void> saveConfig(ConfigModel config) async {
    print("🟡 [StorageService.saveConfig] Salvataggio config...");

    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(config.toJson());
    print("🟡 JSON: $json");

    final encrypted = _encrypter.encrypt(
      json,
      iv: enc.IV.fromLength(16),
    ).base64;

    print("🟡 ENCRYPTED: $encrypted");

    await prefs.setString(_configKey, encrypted);

    print("🟢 Config salvata");
  }

  Future<ConfigModel?> loadConfig() async {
    print("🔵 [StorageService.loadConfig] Caricamento config...");

    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_configKey);

    print("🔵 ENCRYPTED LETTO: $encrypted");

    if (encrypted == null) {
      print("🔴 Nessuna config salvata");
      return null;
    }

    try {
      final decrypted = _encrypter.decrypt(
        enc.Encrypted.fromBase64(encrypted),
        iv: enc.IV.fromLength(16),
      );

      print("🟢 DECRYPTED: $decrypted");

      final json = jsonDecode(decrypted);
      print("🟢 JSON PARSED: $json");

      return ConfigModel.fromJson(json);
    } catch (e) {
      print("🔴 ERRORE decrypt/parse: $e");
      return null;
    }
  }

  // ------------------------------------------------------------
  // APPS
  // ------------------------------------------------------------

  Future<void> saveApps(List<AppModel> apps) async {
    print("🟡 [StorageService.saveApps] Salvataggio apps...");

    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(apps.map((a) => a.toJson()).toList());
    print("🟡 JSON: $json");

    final encrypted = _encrypter.encrypt(
      json,
      iv: enc.IV.fromLength(16),
    ).base64;

    print("🟡 ENCRYPTED: $encrypted");

    await prefs.setString(_appsKey, encrypted);

    print("🟢 Apps salvate");
  }

  Future<List<AppModel>?> loadApps() async {
    print("🔵 [StorageService.loadApps] Caricamento apps...");

    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_appsKey);

    print("🔵 ENCRYPTED LETTO: $encrypted");

    if (encrypted == null) return null;

    try {
      final decrypted = _encrypter.decrypt(
        enc.Encrypted.fromBase64(encrypted),
        iv: enc.IV.fromLength(16),
      );

      print("🟢 DECRYPTED: $decrypted");

      final list = jsonDecode(decrypted) as List;
      print("🟢 JSON PARSED: $list");

      return list.map((e) => AppModel.fromJson(e)).toList();
    } catch (e) {
      print("🔴 ERRORE decrypt/parse: $e");
      return null;
    }
  }

  // ------------------------------------------------------------
  // ORDER
  // ------------------------------------------------------------

  Future<void> saveOrder(List<String> order) async {
    print("🟡 [StorageService.saveOrder] Salvataggio ordine...");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_orderKey, jsonEncode(order));
    print("🟢 Ordine salvato");
  }

  Future<List<String>?> loadOrder() async {
    print("🔵 [StorageService.loadOrder] Caricamento ordine...");
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_orderKey);
    print("🔵 RAW: $raw");

    if (raw == null) return null;

    try {
      final list = List<String>.from(jsonDecode(raw));
      print("🟢 PARSED: $list");
      return list;
    } catch (e) {
      print("🔴 ERRORE parse: $e");
      return null;
    }
  }

  // ------------------------------------------------------------
  // ZOOM
  // ------------------------------------------------------------

  Future<void> saveZoom(double zoom) async {
    print("🟡 [StorageService.saveZoom] Salvataggio zoom: $zoom");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_zoomKey, zoom);
    print("🟢 Zoom salvato");
  }

  Future<double?> loadZoom() async {
    print("🔵 [StorageService.loadZoom] Caricamento zoom...");
    final prefs = await SharedPreferences.getInstance();
    final zoom = prefs.getDouble(_zoomKey);
    print("🟢 Zoom letto: $zoom");
    return zoom;
  }

  // ------------------------------------------------------------
  // RESET TOTALE
  // ------------------------------------------------------------

  Future<void> clearAll() async {
    print("🟡 [StorageService.clearAll] Reset totale...");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configKey);
    await prefs.remove(_appsKey);
    await prefs.remove(_orderKey);
    await prefs.remove(_zoomKey);
    print("🟢 Tutto cancellato");
  }
}
