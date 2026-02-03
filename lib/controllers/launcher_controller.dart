import '../utils/image_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'config_controller.dart';

final launcherProvider = NotifierProvider<LauncherController, LauncherState>(
    () => LauncherController());

class LauncherState {
  final List<AppModel> apps;
  final List<String> order;

  LauncherState({
    required this.apps,
    required this.order,
  });

  LauncherState copyWith({
    List<AppModel>? apps,
    List<String>? order,
  }) {
    return LauncherState(
      apps: apps ?? this.apps,
      order: order ?? this.order,
    );
  }
}

class LauncherController extends Notifier<LauncherState> {
  final api = ApiService();

  @override
  LauncherState build() {
    _init();
    return LauncherState(apps: [], order: []);
  }

  Future<void> _init() async {
    print("🔵 [LauncherController] Init...");

    final cfg = ref.read(configProvider).value;
    if (cfg == null) {
      print("🔴 [LauncherController] Config NULL → non carico apps");
      return;
    }

    final storage = await StorageService.getInstance();

    final savedApps = await storage.loadApps();
    final savedOrder = await storage.loadOrder();

    final apps = savedApps ?? [];
    final order = savedOrder ?? apps.map((a) => a.id).toList();

    print("🟢 [LauncherController] Apps da storage: ${apps.length}");

    state = LauncherState(apps: apps, order: order);

    if (cfg.token != null) {
      print("🟡 [LauncherController] Aggiorno apps dal server...");
      await refreshFromServer();
    }
  }

  // ------------------------------------------------------------
  // MODIFICHE LOCALI
  // ------------------------------------------------------------

  Future<void> renameApp(String id, String newName) async {
    final storage = await StorageService.getInstance();

    final apps = state.apps.map((a) {
      if (a.id == id) {
        return AppModel(
          id: a.id,
          name: newName,
          url: a.url,
          iconDataUrl: a.iconDataUrl,
        );
      }
      return a;
    }).toList();

    await storage.saveApps(apps);
    state = state.copyWith(apps: apps);
  }

  Future<void> changeIcon(String id, List<int> bytes) async {
    final storage = await StorageService.getInstance();

    final newIcon = ImageUtils.bytesToDataUrl(bytes);

    final apps = state.apps.map((a) {
      if (a.id == id) {
        return AppModel(
          id: a.id,
          name: a.name,
          url: a.url,
          iconDataUrl: newIcon,
        );
      }
      return a;
    }).toList();

    await storage.saveApps(apps);
    state = state.copyWith(apps: apps);
  }

  Future<void> removeApp(String id) async {
    final storage = await StorageService.getInstance();

    final apps = state.apps.where((a) => a.id != id).toList();
    final order = state.order.where((o) => o != id).toList();

    await storage.saveApps(apps);
    await storage.saveOrder(order);

    state = LauncherState(apps: apps, order: order);
  }

  // ------------------------------------------------------------
  // RIORDINO
  // ------------------------------------------------------------

  Future<void> reorder(int oldIndex, int newIndex) async {
    final storage = await StorageService.getInstance();

    final newOrder = [...state.order];
    final id = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, id);

    await storage.saveOrder(newOrder);
    state = state.copyWith(order: newOrder);
  }

  // ------------------------------------------------------------
  // REFRESH DAL SERVER
  // ------------------------------------------------------------

  Future<void> refreshFromServer() async {
    final cfg = ref.read(configProvider).value;
    if (cfg == null || cfg.token == null) return;

    final storage = await StorageService.getInstance();

    final apps = await api.fetchApps(cfg, cfg.token!);
    await storage.saveApps(apps);

    final order = apps.map((a) => a.id).toList();
    await storage.saveOrder(order);

    state = LauncherState(apps: apps, order: order);
  }
}
