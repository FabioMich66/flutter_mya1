import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/launcher_controller.dart';
import '../controllers/zoom_controller.dart';
import '../controllers/wiggle_provider.dart';

import '../widgets/app_grid.dart';
import '../widgets/context_menu.dart';
import '../widgets/zoom_wrapper.dart';
import '../widgets/animated_wiggle.dart';

class LauncherPage extends ConsumerWidget {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launcher = ref.watch(launcherProvider);
    final wiggle = ref.watch(wiggleProvider);

    // aggiorna maxZoom in base allo schermo
    ref.read(zoomProvider.notifier).updateMaxZoom(
      MediaQuery.of(context).size.width,
    );

    return GestureDetector(
      // 🔵 TAP FUORI → esce dal wiggle mode
      onTap: () {
        if (wiggle) {
          ref.read(wiggleProvider.notifier).state = false;
        }
      },

      child: Scaffold(
        body: Stack(
          children: [
            ZoomWrapper(
              child: AppGrid(
                apps: launcher.apps,
                order: launcher.order,

                // 🔵 PASSO IL WIGGLE MODE ALLA GRID
                wiggleMode: wiggle,
              ),
            ),

            const ContextMenuOverlay(),
          ],
        ),
      ),
    );
  }
}
