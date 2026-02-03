import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_model.dart';
import '../services/launcher_service.dart';

// CONTROLLERS
import '../controllers/context_menu_controller.dart';
import '../controllers/edit_controller.dart';
import '../controllers/drag_controller.dart';
import '../controllers/launcher_controller.dart';
import '../controllers/wiggle_provider.dart';

// WIDGETS
import '../widgets/animated_wiggle.dart';

class AppIcon extends ConsumerWidget {
  final AppModel app;
  final int index;
  final double zoom;
  final bool wiggleMode;

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

    final size = 78 * zoom; // leggermente ridotto per evitare overflow
    final radius = 16 * zoom;
    final fontSize = 10 * zoom;

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

        // LONG PRESS:
        // - se NON in edit → entra in edit + wiggle
        // - se GIÀ in edit → apre il menu contestuale
        onLongPress: () {
          final isEdit = ref.read(editProvider);
          if (!isEdit) {
            ref.read(editProvider.notifier).enter();
            ref.read(wiggleProvider.notifier).state = true;
          } else {
            final box = context.findRenderObject() as RenderBox;
            final pos = box.localToGlobal(Offset(size * 0.5, size * 0.5));
            ref.read(contextMenuProvider.notifier).show(app.id, pos);
          }
        },

        // TAP → apre app solo se NON in wiggle/edit mode
        onTap: () async {
          if (!wiggleMode && !editMode) {
            await LauncherService().openAsApp(app.url);
          }
        },

        // DRAG → solo in edit mode
        onPanStart: editMode
            ? (details) {
                ref.read(dragProvider.notifier).start(app.id, index);
              }
            : null,

        onPanUpdate: editMode
            ? (details) {
                // 🔵 QUI IL FIX: usiamo il RenderBox della GRID, non dell'icona
                final gridBox =
                    context.findAncestorRenderObjectOfType<RenderBox>();
                if (gridBox == null) return;

                final local = gridBox.globalToLocal(details.globalPosition);

                final launcher = ref.read(launcherProvider);
                final appsCount = launcher.order.length;

                final iconSize = size;
                final spacing = 20 * zoom;
                final cellSize = iconSize + spacing;

                final col = (local.dx / cellSize).floor();
                final row = (local.dy / cellSize).floor();

                final columns =
                    (gridBox.size.width / cellSize).floor().clamp(2, 10);

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
            AnimatedWiggle(
              enabled: wiggleMode,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  SizedBox(height: 4 * zoom),
                  Flexible(
                    child: Text(
                      app.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ),
                ],
              ),
            ),
            if (wiggleMode)
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () {
                    ref.read(launcherProvider.notifier).removeApp(app.id);
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
