import '../utils/image_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'config_controller.dart';

final launcherProvider =
    NotifierProvider<LauncherController, LauncherState>(() => LauncherController());

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
  final storage = StorageService();
  final api = ApiService();

  @override
  LauncherState build() {
    _init();
    return LauncherState(apps: [], order: []);
  }

  Future<void> _init() async {
    final cfg = ref.read(configProvider).value;
    if (cfg == null) return;

    // 1. Carica da storage
    final savedApps = await storage.loadApps();
    final savedOrder = await storage.loadOrder();

    List<AppModel> apps = savedApps ?? [];
    List<String> order = savedOrder ?? apps.map((a) => a.id).toList();

    state = LauncherState(apps: apps, order: order);

    // 2. Aggiorna dal server se c’è un token
    if (cfg.token != null) {
      await refreshFromServer();
    }
  }

  // ------------------------------------------------------------
  // MODIFICHE LOCALI
  // ------------------------------------------------------------

  void renameApp(String id, String newName) {
    final apps = state.apps.map((a) {
      if (a.id == id) return AppModel(id: a.id, name: newName, url: a.url, iconDataUrl: 
a.iconDataUrl);
      return a;
    }).toList();

    storage.saveApps(apps);
    state = state.copyWith(apps: apps);
  }

  void changeIcon(String id, List<int> bytes) {
    final newIcon = ImageUtils.bytesToDataUrl(bytes);

    final apps = state.apps.map((a) {
      if (a.id == id) return AppModel(id: a.id, name: a.name, url: a.url, iconDataUrl: newIcon);
      return a;
    }).toList();

    storage.saveApps(apps);
    state = state.copyWith(apps: apps);
  }

  void removeApp(String id) {
    final apps = state.apps.where((a) => a.id != id).toList();
    final order = state.order.where((o) => o != id).toList();

    storage.saveApps(apps);
    storage.saveOrder(order);

    state = LauncherState(apps: apps, order: order);
  }

  // ------------------------------------------------------------
  // RIORDINO
  // ------------------------------------------------------------

  void reorder(int oldIndex, int newIndex) {
    final newOrder = [...state.order];
    final id = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, id);

    storage.saveOrder(newOrder);
    state = state.copyWith(order: newOrder);
  }

  // ------------------------------------------------------------
  // REFRESH DAL SERVER
  // ------------------------------------------------------------

  Future<void> refreshFromServer() async {
    final cfg = ref.read(configProvider).value;
    if (cfg == null || cfg.token == null) return;

    final apps = await api.fetchApps(cfg, cfg.token!);

    await storage.saveApps(apps);

    final order = apps.map((a) => a.id).toList();
    await storage.saveOrder(order);

    state = LauncherState(apps: apps, order: order);
  }
}



