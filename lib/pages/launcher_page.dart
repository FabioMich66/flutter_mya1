import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/launcher_controller.dart';
import '../widgets/app_grid.dart';
import '../widgets/context_menu.dart';
import '../widgets/zoom_wrapper.dart';
import '../controllers/zoom_controller.dart';

class LauncherPage extends ConsumerWidget {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launcher = ref.watch(launcherProvider);

    // aggiorna maxZoom in base allo schermo
    ref.read(zoomProvider.notifier).updateMaxZoom(MediaQuery.of(context).size.width);

    return Scaffold(
      body: Stack(
        children: [
          ZoomWrapper(
            child: AppGrid(
              apps: launcher.apps,
              order: launcher.order,
            ),
          ),
          const ContextMenuOverlay(),
        ],
      ),
    );
  }
}
