import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../managers/interpreter_manager.dart';

final variablesProvider = Provider<Map<String, dynamic>>((ref) {
  final interpreter = ref.watch(interpreterManagerProvider);
  return interpreter.tablaSimbolos.mapaVariables;
});
