import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/config_model.dart';
import '../models/app_model.dart';

class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  // Chiavi per SharedPreferences
  static const String _configCipherKey = 'config_encrypted';
  static const String _configIvKey = 'config_iv';

  static const String _appsKey = 'apps_encrypted';
  static const String _appsIvKey = 'apps_iv';

  static const String _orderKey = 'apps_order';
  static const String _zoomKey = 'zoom_level';

  // Chiave AES a 32 byte
  static final Key _aesKey = Key.fromUtf8(
    '0123456789ABCDEF0123456789ABCDEF',
  );

  static Future<StorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  Encrypter get _encrypter => Encrypter(
        AES(
          _aesKey,
          mode: AESMode.cbc,
          padding: 'PKCS7',
        ),
      );

  // ------------------------------------------------------------
  // CONFIG
  // ------------------------------------------------------------

  Future<ConfigModel?> loadConfig() async {
    print("🔵 [StorageService.loadConfig] Caricamento config...");

    final encryptedBase64 = _prefs.getString(_configCipherKey);
    final ivBase64 = _prefs.getString(_configIvKey);

    print("🔵 ENCRYPTED LETTO: $encryptedBase64");
    print("🔵 IV LETTO: $ivBase64");

    if (encryptedBase64 == null || ivBase64 == null) {
      print("🔴 Nessuna config salvata");
      return null;
    }

    try {
      final iv = IV.fromBase64(ivBase64);
      final decrypted = _encrypter.decrypt64(encryptedBase64, iv: iv);

      final jsonMap = jsonDecode(decrypted);
      print("🟢 DECRYPTED: $jsonMap");

      return ConfigModel.fromJson(jsonMap);
    } catch (e) {
      print("🔴 ERRORE decrypt/parse: $e");
      return null;
    }
  }

  Future<void> saveConfig(ConfigModel config) async {
    print("🟡 [StorageService.saveConfig] Salvataggio config...");

    final jsonString = jsonEncode(config.toJson());
    print("🟡 JSON: $jsonString");

    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(jsonString, iv: iv);

    await _prefs.setString(_configCipherKey, encrypted.base64);
    await _prefs.setString(_configIvKey, iv.base64);

    print("🟢 Config salvata");
  }

  // ------------------------------------------------------------
  // APPS
  // ------------------------------------------------------------

  Future<void> saveApps(List<AppModel> apps) async {
    print("🟡 [StorageService.saveApps] Salvataggio apps...");

    final jsonString = jsonEncode(apps.map((a) => a.toJson()).toList());

    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(jsonString, iv: iv);

    await _prefs.setString(_appsKey, encrypted.base64);
    await _prefs.setString(_appsIvKey, iv.base64);

    print("🟢 Apps salvate");
  }

  Future<List<AppModel>?> loadApps() async {
    print("🔵 [StorageService.loadApps] Caricamento apps...");

    final encryptedBase64 = _prefs.getString(_appsKey);
    final ivBase64 = _prefs.getString(_appsIvKey);

    if (encryptedBase64 == null || ivBase64 == null) return null;

    try {
      final iv = IV.fromBase64(ivBase64);
      final decrypted = _encrypter.decrypt64(encryptedBase64, iv: iv);

      final list = jsonDecode(decrypted) as List;
      return list.map((e) => AppModel.fromJson(e)).toList();
    } catch (e) {
      print("🔴 ERRORE decrypt/parse apps: $e");
      return null;
    }
  }

  // ------------------------------------------------------------
  // ORDER
  // ------------------------------------------------------------

  Future<void> saveOrder(List<String> order) async {
    await _prefs.setString(_orderKey, jsonEncode(order));
  }

  Future<List<String>?> loadOrder() async {
    final raw = _prefs.getString(_orderKey);
    if (raw == null) return null;

    try {
      return List<String>.from(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // ZOOM
  // ------------------------------------------------------------

  Future<void> saveZoom(double zoom) async {
    await _prefs.setDouble(_zoomKey, zoom);
  }

  Future<double?> loadZoom() async {
    return _prefs.getDouble(_zoomKey);
  }

  // ------------------------------------------------------------
  // RESET
  // ------------------------------------------------------------

  Future<void> clearAll() async {
    await _prefs.remove(_configCipherKey);
    await _prefs.remove(_configIvKey);
    await _prefs.remove(_appsKey);
    await _prefs.remove(_appsIvKey);
    await _prefs.remove(_orderKey);
    await _prefs.remove(_zoomKey);
  }
}
