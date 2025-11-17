import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../managers/execution_controller.dart';

final consoleProvider = Provider<List<String>>((ref) {
  final state = ref.watch(executionControllerProvider);
  return state.consola;
});
