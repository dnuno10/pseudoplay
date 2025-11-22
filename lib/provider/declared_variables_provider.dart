import 'package:flutter_riverpod/flutter_riverpod.dart';

final declaredVariablesProvider =
    StateNotifierProvider<DeclaredVariablesNotifier, List<String>>(
      (ref) => DeclaredVariablesNotifier(),
    );

class DeclaredVariablesNotifier extends StateNotifier<List<String>> {
  DeclaredVariablesNotifier() : super([]);

  void addVariable(String varName) {
    if (!state.contains(varName) && varName.isNotEmpty) {
      state = [...state, varName];
    }
  }

  bool exists(String varName) {
    return state.contains(varName);
  }

  void clear() {
    state = [];
  }

  List<String> getAll() {
    return state;
  }
}
