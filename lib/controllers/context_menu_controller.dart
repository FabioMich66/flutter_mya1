import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContextMenuState {
  final bool visible;
  final Offset position;
  final String? targetId;

  const ContextMenuState({
    required this.visible,
    required this.position,
    required this.targetId,
  });

  ContextMenuState copyWith({
    bool? visible,
    Offset? position,
    String? targetId,
  }) {
    return ContextMenuState(
      visible: visible ?? this.visible,
      position: position ?? this.position,
      targetId: targetId ?? this.targetId,
    );
  }
}

final contextMenuProvider =
    NotifierProvider<ContextMenuController, ContextMenuState>(
        () => ContextMenuController());

class ContextMenuController extends Notifier<ContextMenuState> {
  @override
  ContextMenuState build() =>
      const ContextMenuState(visible: false, position: Offset.zero, targetId: null);

  void show(String id, Offset pos) {
    // Se è già aperto, aggiorna solo posizione e target
    if (state.visible) {
      state = state.copyWith(position: pos, targetId: id);
      return;
    }

    // Altrimenti apri normalmente
    state = ContextMenuState(
      visible: true,
      position: pos,
      targetId: id,
    );
  }

  void hide() {
    if (!state.visible) return;

    state = const ContextMenuState(
      visible: false,
      position: Offset.zero,
      targetId: null,
    );
  }
}

