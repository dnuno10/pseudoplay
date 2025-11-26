import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tuple.dart';
import '../models/token.dart';

final generatorManagerProvider = Provider((ref) => GeneratorManager());

class GeneratorManager {
  GeneratorManager();

  List<Tuple> generar(List<Tuple> estructura) {
    List<Tuple> ejecutables = [];

    final List<int> pilaSi = [];
    final List<int> pilaRepite = [];
    final List<int> pilaFunciones = [];

    for (int i = 0; i < estructura.length; i++) {
      final inst = estructura[i];

      if (inst is AssignTuple) {
        ejecutables.add(
          AssignTuple(
            lineaID: inst.lineaID,
            variable: inst.variable,
            expresion: inst.expresion,
          ),
        );
      } else if (inst is ReadTuple) {
        ejecutables.add(inst);
      } else if (inst is WriteTuple) {
        ejecutables.add(inst);
      } else if (inst is CompareTuple && inst.lineaID == -5000) {
        pilaRepite.add(ejecutables.length);
        ejecutables.add(
          CompareTuple(
            lineaID: inst.lineaID,
            izquierda: inst.izquierda,
            operador: inst.operador,
            derecha: inst.derecha,
          ),
        );
      } else if (inst is CompareTuple) {
        pilaSi.add(ejecutables.length);

        ejecutables.add(
          CompareTuple(
            lineaID: inst.lineaID,
            izquierda: inst.izquierda,
            operador: inst.operador,
            derecha: inst.derecha,
          ),
        );
      } else if (inst.lineaID == -1000) {
        int posIf = pilaSi.removeLast();
        ejecutables[posIf].saltoFalso = ejecutables.length + 1;
        ejecutables.add(Tuple(lineaID: inst.lineaID));

        pilaSi.add(ejecutables.length - 1);
      } else if (inst.lineaID == -2000) {
        int posCond = pilaSi.removeLast();

        if (ejecutables[posCond].lineaID == -1000) {
          ejecutables[posCond].saltoVerdadero = ejecutables.length;
        } else {
          ejecutables[posCond].saltoFalso = ejecutables.length;
        }
      } else if (inst.lineaID == -3000) {
        pilaRepite.add(ejecutables.length);
        ejecutables.add(inst);
      } else if (inst.lineaID == -4000) {
        if (pilaRepite.isEmpty) {
          throw Exception(
            'Error: FinMientras/FinRepite sin MIENTRAS/REPITE correspondiente',
          );
        }
        int inicio = pilaRepite.removeLast();

        if (ejecutables[inicio] is CompareTuple &&
            ejecutables[inicio].lineaID == -5000) {
          ejecutables[inicio].saltoFalso = ejecutables.length + 1;
        }
        ejecutables.add(Tuple(lineaID: inst.lineaID, saltoVerdadero: inicio));
      } else if (inst is FunctionEntryTuple) {
        final entry = FunctionEntryTuple(
          lineaID: inst.lineaID,
          nombre: inst.nombre,
          parametros: List<String>.from(inst.parametros),
        );

        pilaFunciones.add(ejecutables.length);
        ejecutables.add(entry);
      } else if (inst is FunctionEndTuple) {
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
      } else if (inst is FunctionCallTuple) {
        ejecutables.add(
          FunctionCallTuple(
            lineaID: inst.lineaID,
            nombre: inst.nombre,
            argumentos: inst.argumentos
                .map((argumento) => List<Token>.from(argumento))
                .toList(),
          ),
        );
      } else if (inst is EndTuple) {
        ejecutables.add(inst);
      }
    }

    return ejecutables;
  }

  dynamic procesarExpresion(List<Token> tokens, Map<String, dynamic> memoria) {
    return null;
  }
}
