import 'package:flutter_riverpod/flutter_riverpod.dart';

final editorProvider = NotifierProvider<EditorNotifier, String>(
  EditorNotifier.new,
);

class EditorNotifier extends Notifier<String> {
  @override
  String build() => "";

  void updateText(String value) {
    state = value;
  }
}
