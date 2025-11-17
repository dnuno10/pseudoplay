import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../managers/execution_controller.dart';

final variablesProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(executionControllerProvider);
  return state.variables;
});
