import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/zoom_controller.dart';
import '../controllers/drag_controller.dart';
import '../controllers/edit_controller.dart';
import '../models/app_model.dart';
import 'app_icon.dart';

class AppGrid extends ConsumerWidget {
  final List<AppModel> apps;
  final List<String> order;

  const AppGrid({super.key, required this.apps, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(zoomProvider);
    final drag = ref.watch(dragProvider);
    final editMode = ref.watch(editProvider);

    final iconSize = 80 * zoom;
    final spacing = 20 * zoom;

    final width = MediaQuery.of(context).size.width;
    final columns = (width / (iconSize + spacing)).clamp(2, 10).floor();

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.8,
      ),
      itemCount: order.length,
      itemBuilder: (_, i) {
        // sicurezza: se l’indice è fuori range
        if (i >= order.length) return const SizedBox();

        final id = order[i];

        // sicurezza: se l’app non esiste più
        final app = apps.firstWhere(
          (a) => a.id == id,
          orElse: () => AppModel(
            id: id,
            name: 'Unknown',
            url: '',
            iconDataUrl: null,
          ),
        );

        final isPlaceholder =
            editMode &&
            drag.draggingId != null &&
            drag.overIndex == i &&
            drag.overIndex! < order.length;

        if (isPlaceholder) {
          return _PlaceholderIcon(zoom: zoom);
        }

        return AppIcon(app: app, index: i, zoom: zoom);
      },
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  final double zoom;
  const _PlaceholderIcon({required this.zoom});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * zoom),
        border: Border.all(color: Colors.blue.withOpacity(0.4), width: 2),
      ),
    );
  }
}

