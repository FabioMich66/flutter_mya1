import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/config_model.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

final configProvider =
    AsyncNotifierProvider<ConfigController, ConfigModel?>(() {
  return ConfigController();
});

class ConfigController extends AsyncNotifier<ConfigModel?> {
  @override
  Future<ConfigModel?> build() async {
    print("🔵 [ConfigController.build] Avvio caricamento config...");

    final storage = await StorageService.getInstance();
    final cfg = await storage.loadConfig();

    print("🔵 [ConfigController.build] Config caricata: $cfg");

    return cfg;
  }

  // ------------------------------------------------------------
  // LOGIN + SALVATAGGIO + CARICAMENTO APPS
  // ------------------------------------------------------------

  Future<bool> saveAndLogin(ConfigModel config) async {
    print("🟡 [saveAndLogin] Avviato con config: ${config.toJson()}");

    state = const AsyncLoading();

    final api = ApiService();

    print("🟡 [saveAndLogin] Tentativo login...");
    final token = await api.login(config);

    if (token == null) {
      print("🔴 [saveAndLogin] Login fallito");
      state = const AsyncData(null);
      return false;
    }

    print("🟢 [saveAndLogin] TOKEN: $token");

    final updatedConfig = config.copyWith(token: token);

    print(
        "🟡 [saveAndLogin] Config aggiornata con token: ${updatedConfig.toJson()}");

    final storage = await StorageService.getInstance();

    print("🟡 [saveAndLogin] Salvataggio config...");
    await storage.saveConfig(updatedConfig);

    print("🟢 [saveAndLogin] Config salvata");

    print("🟡 [saveAndLogin] Scarico lista app...");
    final apps = await api.fetchApps(updatedConfig, token);

    print("🟢 [saveAndLogin] App scaricate: ${apps.length}");

    // 🔥 NON invalidiamo più il provider
    // Aggiorniamo direttamente lo stato
    state = AsyncData(updatedConfig);

    return true;
  }
}
