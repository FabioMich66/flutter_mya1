import 'package:flutter_riverpod/flutter_riverpod.dart';

class DragState {
  final String? draggingId;
  final int? fromIndex;
  final int? overIndex;

  const DragState({
    this.draggingId,
    this.fromIndex,
    this.overIndex,
  });

  DragState copyWith({
    String? draggingId,
    int? fromIndex,
    int? overIndex,
    bool resetOverIndex = false,
  }) {
    return DragState(
      draggingId: draggingId ?? this.draggingId,
      fromIndex: fromIndex ?? this.fromIndex,
      overIndex: resetOverIndex ? null : (overIndex ?? this.overIndex),
    );
  }
}

final dragProvider =
    NotifierProvider<DragController, DragState>(() => DragController());

class DragController extends Notifier<DragState> {
  @override
  DragState build() => const DragState();

  void start(String id, int index) {
    // evita drag multipli
    if (state.draggingId != null) return;

    state = DragState(
      draggingId: id,
      fromIndex: index,
      overIndex: index,
    );
  }

  void hover(int index, int maxIndex) {
    if (state.draggingId == null) return;

    // evita indici invalidi
    if (index < 0 || index >= maxIndex) return;

    state = state.copyWith(overIndex: index);
  }

  DragState end() {
    final s = state;
    state = const DragState();
    return s;
  }

  void cancel() {
    state = const DragState();
  }
}

