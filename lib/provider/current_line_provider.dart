import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentLineProvider = NotifierProvider<CurrentLineNotifier, int>(
  CurrentLineNotifier.new,
);

class CurrentLineNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setLine(int value) {
    state = value;
  }
}
