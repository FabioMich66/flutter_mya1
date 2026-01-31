import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/context_menu_controller.dart';
import '../controllers/launcher_controller.dart';
import '../utils/image_utils.dart';
import 'rename_dialog.dart';
import '../models/app_model.dart';

class ContextMenuOverlay extends ConsumerWidget {
  const ContextMenuOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(contextMenuProvider);

    if (!menu.visible) return const SizedBox.shrink();

    final screen = MediaQuery.of(context).size;

    // dimensioni menu
    const double menuWidth = 180;
    const double menuHeight = 150;

    // clamp posizione per evitare overflow
    final dx = menu.position.dx.clamp(0, screen.width - menuWidth).toDouble();
    final dy = menu.position.dy.clamp(0, screen.height - menuHeight).toDouble();

    return Stack(
      children: [
        // tappo per chiudere
        Positioned.fill(
          child: GestureDetector(
            onTap: () => ref.read(contextMenuProvider.notifier).hide(),
            behavior: HitTestBehavior.translucent,
          ),
        ),

        // menu
        Positioned(
          left: dx,
          top: dy,
          child: AnimatedScale(
            scale: 1,
            duration: const Duration(milliseconds: 120),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: menuWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _item(context, ref, 'Rinomina', () async {
                      final id = menu.targetId!;
                      final launcher = ref.read(launcherProvider);

                      final app = launcher.apps.firstWhere(
                        (a) => a.id == id,
                        orElse: () => AppModel(
                          id: id,
                          name: 'Unknown',
                          url: '',
                          iconDataUrl: null,
                        ),
                      );

                      final newName = await showDialog<String>(
                        context: context,
                        builder: (_) => RenameDialog(initial: app.name),
                      );

                      if (newName != null && newName.trim().isNotEmpty) {
                        ref
                            .read(launcherProvider.notifier)
                            .renameApp(id, newName.trim());
                      }

                      ref.read(contextMenuProvider.notifier).hide();
                    }),

                    _item(context, ref, 'Cambia icona', () async {
                      final id = menu.targetId!;
                      final bytes = await ImageUtils.pickAndProcessIcon();

                      if (bytes != null) {
                        ref
                            .read(launcherProvider.notifier)
                            .changeIcon(id, bytes);
                      }

                      ref.read(contextMenuProvider.notifier).hide();
                    }),

                    _item(context, ref, 'Rimuovi', () async {
                      final id = menu.targetId!;
                      ref.read(launcherProvider.notifier).removeApp(id);
                      ref.read(contextMenuProvider.notifier).hide();
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    WidgetRef ref,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(label),
      ),
    );
  }
}

