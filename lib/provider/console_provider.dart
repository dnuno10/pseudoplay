import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../managers/interpreter_manager.dart';

final consoleProvider = Provider<List<String>>((ref) {
  final interpreter = ref.watch(interpreterManagerProvider);
  return interpreter.estado.consola;
});
