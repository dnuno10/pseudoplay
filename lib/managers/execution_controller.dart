import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tuple.dart';
import '../managers/lexer_manager.dart';
import '../managers/parser_manager.dart';
import '../managers/generator_manager.dart';
import '../managers/interpreter_manager.dart';
import '../provider/user_preferences_provider.dart';
import '../utils/lexical_exception.dart';
import '../utils/syntax_coach.dart';
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
  final bool esperandoInput;
  final String? variableInput;

  const ExecutionState({
    required this.tuplas,
    required this.variables,
    required this.consola,
    required this.deskCheck,
    required this.lineaActual,
    this.error,
    this.listo = false,
    this.esperandoInput = false,
    this.variableInput,
  });

  factory ExecutionState.initial() => const ExecutionState(
    tuplas: [],
    variables: {},
    consola: [],
    deskCheck: [],
    lineaActual: 0,
    listo: false,
    error: null,
    esperandoInput: false,
    variableInput: null,
  );

  ExecutionState copyWith({
    List<Tuple>? tuplas,
    String? error,
    bool? listo,
    Map<String, dynamic>? variables,
    List<String>? consola,
    List<Map<String, dynamic>>? deskCheck,
    int? lineaActual,
    bool? esperandoInput,
    String? variableInput,
    bool clearError = false,
    bool clearInput = false,
  }) {
    return ExecutionState(
      tuplas: tuplas ?? this.tuplas,
      error: clearError ? null : (error ?? this.error),
      listo: listo ?? this.listo,
      variables: variables ?? this.variables,
      consola: consola ?? this.consola,
      deskCheck: deskCheck ?? this.deskCheck,
      lineaActual: lineaActual ?? this.lineaActual,
      esperandoInput: esperandoInput ?? this.esperandoInput,
      variableInput: clearInput ? null : (variableInput ?? this.variableInput),
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

      if (tuplas.isNotEmpty) {
        unawaited(
          ref.read(userPreferencesProvider.notifier).incrementAlgorithms(),
        );
      }

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
      state = state.copyWith(
        error: SyntaxCoach.friendlyError(codigo, e.toString()),
        listo: false,
      );
    } on SyntaxException catch (e) {
      state = state.copyWith(
        error: SyntaxCoach.friendlyError(codigo, e.toString()),
        listo: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: SyntaxCoach.friendlyError(codigo, e.toString()),
        listo: false,
      );
    }
  }

  /// ------------------------------------------------------
  /// EJECUTAR 1 PASO
  /// ------------------------------------------------------
  void ejecutarPaso() {
    if (!state.listo) return; // Si no está listo, no hacer nada
    final interprete = ref.read(interpreterManagerProvider);

    // Verificar si ya terminó la ejecución
    if (interprete.estado.lineaActual >= interprete.instrucciones.length) {
      return;
    }

    // Verificar si la siguiente instrucción es un LEER
    final siguienteInstruccion =
        interprete.instrucciones[interprete.estado.lineaActual];
    if (siguienteInstruccion is ReadTuple) {
      print(
        '[CONTROLLER] Detectado ReadTuple para variable: ${siguienteInstruccion.variable}',
      );
      print('[CONTROLLER] Pausando ejecución para esperar input');
      // Pausar y esperar input
      state = state.copyWith(
        esperandoInput: true,
        variableInput: siguienteInstruccion.variable,
      );
      return;
    }

    interprete.ejecutarPaso();

    state = state.copyWith(
      variables: Map.unmodifiable(interprete.tablaSimbolos.mapaVariables),
      consola: List.unmodifiable(interprete.estado.consola),
      deskCheck: List.unmodifiable(_buildDeskCheckRows(interprete)),
      lineaActual: interprete.estado.lineaActual,
    );
  }

  /// ------------------------------------------------------
  /// CONTINUAR DESPUÉS DE RECIBIR INPUT
  /// ------------------------------------------------------
  void continuarConInput(String inputValue) {
    if (!state.esperandoInput || state.variableInput == null) return;

    final interprete = ref.read(interpreterManagerProvider);

    // Convertir el input a número
    final valor = double.tryParse(inputValue) ?? 0.0;

    print(
      '[CONTROLLER] continuarConInput: variable=${state.variableInput}, valor=$valor',
    );

    // Actualizar la variable en la tabla de símbolos
    interprete.tablaSimbolos.actualizar(state.variableInput!, valor);

    print(
      '[CONTROLLER] Tabla después de actualizar: ${interprete.tablaSimbolos.mapaVariables}',
    );

    // Registrar en desk check
    interprete.estado.registrarPaso(
      linea: 'Línea ${interprete.estado.lineaActual + 1}',
      variables: Map.from(interprete.tablaSimbolos.mapaVariables),
      operacion: 'LEER',
      variable: state.variableInput!,
      valorNuevo: valor.toString(),
    );

    // Avanzar a la siguiente línea
    interprete.estado.lineaActual++;

    // Actualizar el estado
    state = state.copyWith(
      esperandoInput: false,
      variables: Map.unmodifiable(interprete.tablaSimbolos.mapaVariables),
      consola: List.unmodifiable(interprete.estado.consola),
      deskCheck: List.unmodifiable(_buildDeskCheckRows(interprete)),
      lineaActual: interprete.estado.lineaActual,
      clearInput: true,
    );
  }

  /// ------------------------------------------------------
  /// RETROCEDER 1 PASO
  /// ------------------------------------------------------
  void retrocederPaso() {
    if (!state.listo) return;
    final interprete = ref.read(interpreterManagerProvider);

    // Retroceder en el intérprete
    if (interprete.estado.lineaActual > 0) {
      interprete.estado.lineaActual--;
    }

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

    // Mantener las tuplas procesadas pero resetear el estado
    state = state.copyWith(
      variables: const {},
      consola: const [],
      deskCheck: const [],
      lineaActual: 0,
      esperandoInput: false,
      clearInput: true,
      clearError: true,
    );
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
