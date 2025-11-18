import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tuple.dart';
import '../models/token.dart';

final generatorManagerProvider = Provider((ref) => GeneratorManager());

class GeneratorManager {
  GeneratorManager();

  /// --------------------------------------------------------------
  /// MÉTODO PRINCIPAL: Recibe las tuplas preliminares del Parser
  /// y genera tuplas listas para el intérprete.
  /// --------------------------------------------------------------
  List<Tuple> generar(List<Tuple> estructura) {
    List<Tuple> ejecutables = [];

    final List<int> pilaSi = [];
    final List<int> pilaRepite = [];
    final List<int> pilaFunciones = [];

    for (int i = 0; i < estructura.length; i++) {
      final inst = estructura[i];

      // -------------------------------
      // ASIGNACIONES
      // -------------------------------
      if (inst is AssignTuple) {
        ejecutables.add(
          AssignTuple(
            lineaID: inst.lineaID,
            variable: inst.variable,
            expresion: inst.expresion,
          ),
        );
      }
      // -------------------------------
      // LEER
      // -------------------------------
      else if (inst is ReadTuple) {
        ejecutables.add(inst);
      }
      // -------------------------------
      // ESCRIBIR
      // -------------------------------
      else if (inst is WriteTuple) {
        ejecutables.add(inst);
      }
      // -------------------------------
      // SI (COMPARACIÓN)
      // -------------------------------
      else if (inst is CompareTuple) {
        pilaSi.add(ejecutables.length);

        ejecutables.add(
          CompareTuple(
            lineaID: inst.lineaID,
            izquierda: inst.izquierda,
            operador: inst.operador,
            derecha: inst.derecha,
          ),
        );
      }
      // -------------------------------
      // SINO
      // -------------------------------
      else if (inst.lineaID == -1000) {
        int posIf = pilaSi.removeLast();
        ejecutables[posIf].saltoFalso = ejecutables.length + 1;

        ejecutables.add(Tuple(lineaID: inst.lineaID));

        pilaSi.add(ejecutables.length - 1);
      }
      // -------------------------------
      // FINSI
      // -------------------------------
      else if (inst.lineaID == -2000) {
        int posCond = pilaSi.removeLast();
        ejecutables[posCond].saltoFalso = ejecutables.length;
      }
      // -------------------------------
      // REPITE
      // -------------------------------
      else if (inst.lineaID == -3000) {
        pilaRepite.add(ejecutables.length);
        ejecutables.add(inst);
      }
      // -------------------------------
      // FINREPITE
      // -------------------------------
      else if (inst.lineaID == -4000) {
        int inicio = pilaRepite.removeLast();
        ejecutables.add(Tuple(lineaID: inst.lineaID, saltoVerdadero: inicio));
      }
      // -------------------------------
      // ENTRADA DE FUNCIÓN
      // -------------------------------
      else if (inst is FunctionEntryTuple) {
        final entry = FunctionEntryTuple(
          lineaID: inst.lineaID,
          nombre: inst.nombre,
          parametros: List<String>.from(inst.parametros),
        );

        pilaFunciones.add(ejecutables.length);
        ejecutables.add(entry);
      }
      // -------------------------------
      // FIN DE FUNCIÓN
      // -------------------------------
      else if (inst is FunctionEndTuple) {
        final fin = FunctionEndTuple(
          lineaID: inst.lineaID,
          nombre: inst.nombre,
        );

        ejecutables.add(fin);

        if (pilaFunciones.isNotEmpty) {
          final idx = pilaFunciones.removeLast();
          final entry = ejecutables[idx];
          if (entry is FunctionEntryTuple) {
            entry.saltoVerdadero = ejecutables.length;
          }
        }
      }
      // -------------------------------
      // LLAMADA A FUNCIÓN
      // -------------------------------
      else if (inst is FunctionCallTuple) {
        ejecutables.add(
          FunctionCallTuple(
            lineaID: inst.lineaID,
            nombre: inst.nombre,
            argumentos: inst.argumentos
                .map((argumento) => List<Token>.from(argumento))
                .toList(),
          ),
        );
      }
      // -------------------------------
      // FIN DE PROGRAMA
      // -------------------------------
      else if (inst is EndTuple) {
        ejecutables.add(inst);
      }
    }

    return ejecutables;
  }

  /// --------------------------------------------------------------
  /// CONVERTIR EXPRESIÓN A VALOR (Para el intérprete)
  /// --------------------------------------------------------------
  dynamic procesarExpresion(List<Token> tokens, Map<String, dynamic> memoria) {
    // En Fase 4 esta función será completada (evaluación real)
    return null;
  }
}
