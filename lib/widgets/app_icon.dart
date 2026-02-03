import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/context_menu_controller.dart';
import '../controllers/edit_controller.dart';
import '../controllers/drag_controller.dart';
import '../controllers/launcher_controller.dart';
import '../controllers/wiggle_provider.dart';

import '../services/launcher_service.dart';
import '../models/app_model.dart';
import '../widgets/animated_wiggle.dart';

import 'package:flutter/gestures.dart';

class AppIcon extends ConsumerWidget {
  final AppModel app;
  final int index;
  final double zoom;
  final bool wiggleMode; // 🔵 nuovo parametro

  const AppIcon({
    super.key,
    required this.app,
    required this.index,
    required this.zoom,
    required this.wiggleMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editMode = ref.watch(editProvider);

    final size = 80 * zoom;
    final radius = 16 * zoom;
    final fontSize = 11 * zoom;

    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton &&
            editMode) {
          ref.read(contextMenuProvider.notifier).show(
                app.id,
                event.position,
              );
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,

        // 🔵 LONG PRESS → entra in wiggle mode
        onLongPress: () {
          ref.read(wiggleProvider.notifier).state = true;
        },

        // 🔵 TAP → apre l’app se NON sei in wiggle/edit mode
        onTap: () async {
          if (!wiggleMode && !editMode) {
            await LauncherService().openAsApp(app.url);
          }
        },

        // 🔵 DRAG rimane invariato
        onPanStart: editMode
            ? (details) {
                ref.read(dragProvider.notifier).start(app.id, index);
              }
            : null,

        onPanUpdate: editMode
            ? (details) {
                final gridBox = context.findRenderObject() as RenderBox;
                final local = gridBox.globalToLocal(details.globalPosition);

                final launcher = ref.read(launcherProvider);
                final appsCount = launcher.order.length;

                final iconSize = size;
                final spacing = 20 * zoom;
                final cellSize = iconSize + spacing;

                final col = (local.dx / cellSize).floor();
                final row = (local.dy / cellSize).floor();

                final columns = (gridBox.size.width / cellSize)
                    .floor()
                    .clamp(2, 10);

                final newIndex = row * columns + col;

                ref.read(dragProvider.notifier).hover(newIndex, appsCount);
              }
            : null,

        onPanEnd: editMode
            ? (details) {
                final dragState = ref.read(dragProvider.notifier).end();

                if (dragState.draggingId != null &&
                    dragState.fromIndex != null &&
                    dragState.overIndex != null) {
                  ref
                      .read(launcherProvider.notifier)
                      .reorder(dragState.fromIndex!, dragState.overIndex!);
                }
              }
            : null,

        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 🔵 ANIMAZIONE WIGGLE
            AnimatedWiggle(
              enabled: wiggleMode,
              child: Column(
                children: [
                  SizedBox(
                    width: size,
                    height: size,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: app.iconDataUrl != null
                          ? Image.memory(
                              Uri.parse(app.iconDataUrl!)
                                  .data!
                                  .contentAsBytes(),
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 6 * zoom),
                  Text(
                    app.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
            ),

            // 🔴 PULSANTE DELETE (solo in wiggle mode)
            if (wiggleMode)
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(launcherProvider.notifier)
                        .removeApp(app.id);
                  },
                  child: Container(
                    width: 24 * zoom,
                    height: 24 * zoom,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14 * zoom,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
