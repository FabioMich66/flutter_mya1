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
    final cfg = await storage.loadConfig();
    return cfg;
  }

  Future<bool> saveAndLogin(ConfigModel config) async {
    state = const AsyncLoading();

    // 1. LOGIN
    final token = await api.login(config);

    if (token == null) {
      state = AsyncError("Credenziali errate", StackTrace.current);
      return false;
    }

    // 2. Aggiorna config con token
    final updatedConfig = config.copyWith(token: token);

    // 3. Salva config completa
    await storage.saveConfig(updatedConfig);

    // 4. Scarica le app
    final apps = await api.fetchApps(updatedConfig, token);

    // 5. Salva le app nello storage
    await storage.saveApps(apps);

    // 6. Aggiorna provider delle app
    ref.read(appsProvider.notifier).state = apps;

    // 7. Aggiorna stato Riverpod
    state = AsyncData(updatedConfig);

    return true;
  }
}

