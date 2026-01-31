import 'package:flutter_riverpod/flutter_riverpod.dart';

final editProvider =
    NotifierProvider<EditController, bool>(() => EditController());

class EditController extends Notifier<bool> {
  @override
  bool build() => false;

  void enter() => state = true;

  void exit() => state = false;

  void toggle() => state = !state;

  void setMode(bool value) => state = value;
}

