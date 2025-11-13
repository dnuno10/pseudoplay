import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../managers/interpreter_manager.dart';

final deskCheckProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final interpreter = ref.watch(interpreterManagerProvider);
  return interpreter.estado.historialVariables;
});
