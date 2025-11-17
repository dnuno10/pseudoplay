import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que mantiene el historial de variables declaradas
final declaredVariablesProvider =
    StateNotifierProvider<DeclaredVariablesNotifier, List<String>>(
      (ref) => DeclaredVariablesNotifier(),
    );

class DeclaredVariablesNotifier extends StateNotifier<List<String>> {
  DeclaredVariablesNotifier() : super([]);

  /// Agregar una variable al historial
  void addVariable(String varName) {
    if (!state.contains(varName) && varName.isNotEmpty) {
      state = [...state, varName];
    }
  }

  /// Verificar si una variable existe
  bool exists(String varName) {
    return state.contains(varName);
  }

  /// Limpiar todas las variables
  void clear() {
    state = [];
  }

  /// Obtener lista de variables
  List<String> getAll() {
    return state;
  }
}
