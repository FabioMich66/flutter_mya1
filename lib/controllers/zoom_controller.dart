import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../services/storage_service.dart';

final zoomProvider =
    NotifierProvider<ZoomController, double>(() => ZoomController());

class ZoomController extends Notifier<double> {
  double minZoom = 0.5;
  double maxZoom = 4.0;

  @override
  double build() {
    _load();
    return 1.0;
  }

  Future<void> _load() async {
    final storage = await StorageService.getInstance();
    final z = await storage.loadZoom();
    if (z != null) {
      state = z;
      print("🟢 [ZoomController] Zoom caricato: $z");
    } else {
      print("🔵 [ZoomController] Nessun zoom salvato, uso default 1.0");
    }
  }

  void updateMaxZoom(double screenWidth) {
    maxZoom = min(screenWidth / 85, 4.0);
  }

  Future<void> applyZoom(double z) async {
    final storage = await StorageService.getInstance();

    final clamped = z.clamp(minZoom, maxZoom);
    state = clamped;

    await storage.saveZoom(clamped);
    print("🟢 [ZoomController] Zoom salvato: $clamped");
  }

  double applyElastic(double z) {
    if (z > maxZoom) {
      return maxZoom + (z - maxZoom) * 0.25;
    }
    if (z < minZoom) {
      return minZoom - (minZoom - z) * 0.25;
    }
    return z;
  }
}
