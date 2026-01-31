import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/context_menu_controller.dart';
import '../controllers/edit_controller.dart';
import '../controllers/drag_controller.dart';
import '../controllers/launcher_controller.dart';
import '../services/launcher_service.dart';
import '../models/app_model.dart';
import 'package:flutter/gestures.dart';

class AppIcon extends ConsumerWidget {
  final AppModel app;
  final int index;
  final double zoom;

  const AppIcon({
    super.key,
    required this.app,
    required this.index,
    required this.zoom,
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

        onLongPress: () {
          if (editMode) {
            final box = context.findRenderObject() as RenderBox;
            final pos = box.localToGlobal(Offset(size * 0.5, size * 0.5));
            ref.read(contextMenuProvider.notifier).show(app.id, pos);
          } else {
            ref.read(editProvider.notifier).enter();
          }
        },

        onTap: () async {
          if (!editMode) {
            await LauncherService().openAsApp(app.url);
          }
        },

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

                final columns = (gridBox.size.width / cellSize).floor().clamp(2, 10);
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

        child: Column(
          children: [
            SizedBox(
              width: size,
              height: size,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: app.iconDataUrl != null
                    ? Image.memory(
                        Uri.parse(app.iconDataUrl!).data!.contentAsBytes(),
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
    );
  }
}

