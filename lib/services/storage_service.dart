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
    print("🟡 [StorageService.saveConfig] Avvio salvataggio config...");
    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(config.toJson());
    print("🟡 [StorageService.saveConfig] JSON da salvare: $json");

    final encrypted = _encrypter.encrypt(
      json,
      iv: enc.IV.fromLength(16),
    ).base64;

    print("🟡 [StorageService.saveConfig] ENCRYPTED: $encrypted");

    await prefs.setString(_configKey, encrypted);

    print("🟢 [StorageService.saveConfig] Config salvata in SharedPreferences");
  }

  Future<ConfigModel?> loadConfig() async {
    print("🔵 [StorageService.loadConfig] Caricamento config...");
    final prefs = await SharedPreferences.getInstance();

    final encrypted = prefs.getString(_configKey);
    print("🔵 [StorageService.loadConfig] ENCRYPTED LETTO: $encrypted");

    if (encrypted == null) {
      print("🔴 [StorageService.loadConfig] Nessuna config salvata");
      return null;
    }

    try {
      final decrypted = _encrypter.decrypt(
        enc.Encrypted.fromBase64(encrypted),
        iv: enc.IV.fromLength(16),
      );

      print("🟢 [StorageService.loadConfig] DECRYPTED: $decrypted");

      final json = jsonDecode(decrypted);
      print("🟢 [StorageService.loadConfig] JSON PARSED: $json");

      return ConfigModel.fromJson(json);
    } catch (e) {
      print("🔴 [StorageService.loadConfig] ERRORE decrypt/parse: $e");
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
    print("🟡 [StorageService.saveApps] JSON: $json");

    final encrypted = _encrypter.encrypt(
      json,
      iv: enc.IV.fromLength(16),
    ).base64;

    print("🟡 [StorageService.saveApps] ENCRYPTED: $encrypted");

    await prefs.setString(_appsKey, encrypted);

    print("🟢 [StorageService.saveApps] Apps salvate");
  }

  Future<List<AppModel>?> loadApps() async {
    print("🔵 [StorageService.loadApps] Caricamento apps...");
    final prefs = await SharedPreferences.getInstance();

    final encrypted = prefs.getString(_appsKey);
    print("🔵 [StorageService.loadApps] ENCRYPTED LETTO: $encrypted");

    if (encrypted == null) return null;

    try {
      final decrypted = _encrypter.decrypt(
        enc.Encrypted.fromBase64(encrypted),
        iv: enc.IV.fromLength(16),
      );

      print("🟢 [StorageService.loadApps] DECRYPTED: $decrypted");

      final list = jsonDecode(decrypted) as List;
      print("🟢 [StorageService.loadApps] JSON PARSED: $list");

      return list.map((e) => AppModel.fromJson(e)).toList();
    } catch (e) {
      print("🔴 [StorageService.loadApps] ERRORE decrypt/parse: $e");
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
    print("🟢 [StorageService.saveOrder] Ordine salvato");
  }

  Future<List<String>?> loadOrder() async {
    print("🔵 [StorageService.loadOrder] Caricamento ordine...");
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_orderKey);
    print("🔵 [StorageService.loadOrder] RAW: $raw");

    if (raw == null) return null;

    try {
      final list = List<String>.from(jsonDecode(raw));
      print("🟢 [StorageService.loadOrder] PARSED: $list");
      return list;
    } catch (e) {
      print("🔴 [StorageService.loadOrder] ERRORE parse: $e");
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
    print("🟢 [StorageService.saveZoom] Zoom salvato");
  }

  Future<double?> loadZoom() async {
    print("🔵 [StorageService.loadZoom] Caricamento zoom...");
    final prefs = await SharedPreferences.getInstance();
    final zoom = prefs.getDouble(_zoomKey);
    print("🟢 [StorageService.loadZoom] Zoom letto: $zoom");
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
    print("🟢 [StorageService.clearAll] Tutto cancellato");
  }
}
