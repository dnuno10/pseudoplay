import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tuple.dart';
import '../managers/lexer_manager.dart';
import '../managers/parser_manager.dart';
import '../managers/generator_manager.dart';
import '../managers/interpreter_manager.dart';
import '../utils/lexical_exception.dart';
import '../utils/syntax_exception.dart';

final executionControllerProvider =
    NotifierProvider<ExecutionController, ExecutionState>(
      ExecutionController.new,
    );

class ExecutionState {
  final List<Tuple> tuplas;
  final String? error;
  final bool listo;
  final Map<String, dynamic> variables;
  final List<String> consola;
  final List<Map<String, dynamic>> deskCheck;
  final int lineaActual;

  const ExecutionState({
    required this.tuplas,
    required this.variables,
    required this.consola,
    required this.deskCheck,
    required this.lineaActual,
    this.error,
    this.listo = false,
  });

  factory ExecutionState.initial() => const ExecutionState(
    tuplas: [],
    variables: {},
    consola: [],
    deskCheck: [],
    lineaActual: 0,
    listo: false,
    error: null,
  );

  ExecutionState copyWith({
    List<Tuple>? tuplas,
    String? error,
    bool? listo,
    Map<String, dynamic>? variables,
    List<String>? consola,
    List<Map<String, dynamic>>? deskCheck,
    int? lineaActual,
    bool clearError = false,
  }) {
    return ExecutionState(
      tuplas: tuplas ?? this.tuplas,
      error: clearError ? null : (error ?? this.error),
      listo: listo ?? this.listo,
      variables: variables ?? this.variables,
      consola: consola ?? this.consola,
      deskCheck: deskCheck ?? this.deskCheck,
      lineaActual: lineaActual ?? this.lineaActual,
    );
  }
}

class ExecutionController extends Notifier<ExecutionState> {
  @override
  ExecutionState build() => ExecutionState.initial();

  /// ------------------------------------------------------
  /// FLUJO PRINCIPAL: ANALIZAR, PARSEAR, GENERAR
  /// ------------------------------------------------------
  void procesarCodigo(String codigo) {
    final lexer = ref.read(lexerManagerProvider);
    final parser = ref.read(parserManagerProvider);
    final generador = ref.read(generatorManagerProvider);
    final interprete = ref.read(interpreterManagerProvider);

    try {
      // 1. Tokenizar
      final tokens = lexer.analizar(codigo);

      // 2. Validar sintaxis
      parser.validarSintaxis(tokens);

      // 3. Parsear
      final estructura = parser.parsear(tokens);

      // 4. Generar tuplas finales
      final tuplas = generador.generar(estructura);

      // 5. Cargar al intérprete
      interprete.cargarPrograma(tuplas);

      state = state.copyWith(
        tuplas: List.unmodifiable(tuplas),
        listo: true,
        variables: const {},
        consola: const [],
        deskCheck: const [],
        lineaActual: 0,
        clearError: true,
      );
    } on LexicalException catch (e) {
      state = state.copyWith(error: e.toString(), listo: false);
    } on SyntaxException catch (e) {
      state = state.copyWith(error: e.toString(), listo: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), listo: false);
    }
  }

  /// ------------------------------------------------------
  /// EJECUTAR 1 PASO
  /// ------------------------------------------------------
  void ejecutarPaso() {
    if (!state.listo) return;
    final interprete = ref.read(interpreterManagerProvider);
    interprete.ejecutarPaso();

    state = state.copyWith(
      variables: Map.unmodifiable(interprete.tablaSimbolos.mapaVariables),
      consola: List.unmodifiable(interprete.estado.consola),
      deskCheck: List.unmodifiable(_buildDeskCheckRows(interprete)),
      lineaActual: interprete.estado.lineaActual,
    );
  }

  /// ------------------------------------------------------
  /// REINICIAR PROGRAMA
  /// ------------------------------------------------------
  void reiniciar() {
    final interprete = ref.read(interpreterManagerProvider);
    interprete.reset();

    state = ExecutionState.initial();
  }

  List<Map<String, dynamic>> _buildDeskCheckRows(
    InterpreterManager interprete,
  ) {
    if (interprete.estado.pasos.isEmpty) return const [];

    return interprete.estado.pasos
        .map(
          (paso) => {
            'linea': paso.linea,
            'operacion': paso.operacion,
            'variable': paso.variable,
            'valorNuevo': paso.valorNuevo,
          },
        )
        .toList(growable: false);
  }
}
