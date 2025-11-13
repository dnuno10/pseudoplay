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

  const ExecutionState({required this.tuplas, this.error, this.listo = false});

  ExecutionState copiar({List<Tuple>? tuplas, String? error, bool? listo}) {
    return ExecutionState(
      tuplas: tuplas ?? this.tuplas,
      error: error,
      listo: listo ?? this.listo,
    );
  }
}

class ExecutionController extends Notifier<ExecutionState> {
  @override
  ExecutionState build() => const ExecutionState(tuplas: []);

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

      state = state.copiar(tuplas: tuplas, error: null, listo: true);
    } on LexicalException catch (e) {
      state = state.copiar(error: e.toString(), listo: false);
    } on SyntaxException catch (e) {
      state = state.copiar(error: e.toString(), listo: false);
    } catch (e) {
      state = state.copiar(error: e.toString(), listo: false);
    }
  }

  /// ------------------------------------------------------
  /// EJECUTAR 1 PASO
  /// ------------------------------------------------------
  void ejecutarPaso() {
    final interprete = ref.read(interpreterManagerProvider);
    interprete.ejecutarPaso();
  }

  /// ------------------------------------------------------
  /// REINICIAR PROGRAMA
  /// ------------------------------------------------------
  void reiniciar() {
    final interprete = ref.read(interpreterManagerProvider);
    interprete.reset();

    state = state.copiar(listo: false);
  }
}
