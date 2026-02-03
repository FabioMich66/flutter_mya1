import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/zoom_controller.dart';
import '../controllers/edit_controller.dart';
import 'package:flutter/gestures.dart';

class ZoomWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const ZoomWrapper({super.key, required this.child});

  @override
  ConsumerState<ZoomWrapper> createState() => _ZoomWrapperState();
}

class _ZoomWrapperState extends ConsumerState<ZoomWrapper> {
  double gestureStartZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    final editMode = ref.watch(editProvider);
    final zoomCtrl = ref.read(zoomProvider.notifier);

    return Listener(
      onPointerSignal: (signal) {
        if (!editMode) return; // zoom solo in edit mode
        if (signal is PointerScrollEvent) {
          final current = ref.read(zoomProvider);
          final direction = signal.scrollDelta.dy < 0 ? 1 : -1;
          final factor = 1 + direction * 0.08;
          final newZoom = zoomCtrl.applyElastic(current * factor);
          zoomCtrl.applyZoom(newZoom);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild, // 🔵 NON blocca gli eventi

        onScaleStart: editMode
            ? (details) {
                gestureStartZoom = ref.read(zoomProvider);
              }
            : null,

        onScaleUpdate: editMode
            ? (details) {
                final newZoom = zoomCtrl.applyElastic(
                  gestureStartZoom * details.scale,
                );
                zoomCtrl.applyZoom(newZoom);
              }
            : null,

        child: widget.child,
      ),
    );
  }
}
