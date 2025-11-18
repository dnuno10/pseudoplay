import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para la velocidad de ejecución
/// 0 = Manual, otros valores = segundos de delay
final executionSpeedProvider = StateProvider<double>((ref) => 1.0);
