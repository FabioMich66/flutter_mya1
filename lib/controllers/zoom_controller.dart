import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../services/storage_service.dart';

final zoomProvider =
    NotifierProvider<ZoomController, double>(() => ZoomController());

class ZoomController extends Notifier<double> {
  final storage = StorageService();

  double minZoom = 0.5;
  double maxZoom = 4.0;

  @override
  double build() {
    _load();
    return 1.0;
  }

  Future<void> _load() async {
    final z = await storage.loadZoom();
    if (z != null) state = z;
  }

  void updateMaxZoom(double screenWidth) {
    maxZoom = min(screenWidth / 85, 4.0);
  }

  void applyZoom(double z) {
    final clamped = z.clamp(minZoom, maxZoom);
    state = clamped;
    storage.saveZoom(clamped);
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
