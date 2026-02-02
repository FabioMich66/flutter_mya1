import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/config_model.dart';
import '../models/app_model.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

final configProvider =
    AsyncNotifierProvider<ConfigController, ConfigModel?>(() => ConfigController());

final appsProvider =
    StateProvider<List<AppModel>>((ref) => []);

class ConfigController extends AsyncNotifier<ConfigModel?> {
  final storage = StorageService();
  final api = ApiService();

  @override
  Future<ConfigModel?> build() async {
    print("🔵 [ConfigController.build] Avvio caricamento config...");
    final cfg = await storage.loadConfig();
    print("🔵 [ConfigController.build] Config caricata: ${cfg?.toJson()}");
    return cfg;
  }

  Future<bool> saveAndLogin(ConfigModel config) async {
    print("🟡 [saveAndLogin] Avviato con config: ${config.toJson()}");

    state = const AsyncLoading();
    print("🟡 [saveAndLogin] Stato impostato a AsyncLoading");

    // 1. LOGIN
    print("🟡 [saveAndLogin] Tentativo login...");
    final token = await api.login(config);
    print("🟡 [saveAndLogin] Risposta login → token: $token");

    if (token == null) {
      print("🔴 [saveAndLogin] Login fallito");
      state = AsyncError("Credenziali errate", StackTrace.current);
      return false;
    }

    // 2. Aggiorna config con token
    final updatedConfig = config.copyWith(token: token);
    print("🟡 [saveAndLogin] Config aggiornata con token: ${updatedConfig.toJson()}");

    // 3. Salva config completa
    print("🟡 [saveAndLogin] Salvataggio config...");
    await storage.saveConfig(updatedConfig);
    print("🟢 [saveAndLogin] Config salvata");

    // 🔥 FIX: ricostruisci il provider 
    print("🟡 [saveAndLogin] Invalido il provider per ricaricare la config...");
    ref.invalidateSelf();

    // 4. Scarica le app
    print("🟡 [saveAndLogin] Scarico lista app...");
    final apps = await api.fetchApps(updatedConfig, token);
    print("🟢 [saveAndLogin] App scaricate: ${apps.length}");

    // 5. Salva le app nello storage
    print("🟡 [saveAndLogin] Salvataggio app...");
    await storage.saveApps(apps);
    print("🟢 [saveAndLogin] App salvate");

    // 6. Aggiorna provider delle app
    print("🟡 [saveAndLogin] Aggiorno appsProvider...");
    ref.read(appsProvider.notifier).state = apps;

    // 7. Aggiorna stato Riverpod
    print("🟡 [saveAndLogin] Imposto stato finale AsyncData");
    state = AsyncData(updatedConfig);

    print("🟢 [saveAndLogin] COMPLETATO CON SUCCESSO");
    return true;
  }
}
