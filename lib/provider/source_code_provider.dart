import 'package:flutter_riverpod/flutter_riverpod.dart';

final sourceCodeProvider = NotifierProvider<SourceCodeNotifier, List<String>>(
  SourceCodeNotifier.new,
);

class SourceCodeNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void replaceLines(List<String> lines) {
    state = List.unmodifiable(lines);
  }
}
