import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_state.dart';
import '../models/symbol_table.dart';
import '../models/tuple.dart';
import '../models/token.dart';
import '../models/tipo_token.dart';

final interpreterManagerProvider = Provider((ref) => InterpreterManager());

class InterpreterManager {
  final ProgramState estado = ProgramState();
  final SymbolTable tablaSimbolos = SymbolTable();

  List<Tuple> instrucciones = [];

  /// Cargar tuplas generadas
  void cargarPrograma(List<Tuple> tuplas) {
    instrucciones = tuplas;
    estado.reset();
  }

  /// Ejecutar un paso
  void ejecutarPaso() {
    if (estado.lineaActual >= instrucciones.length) {
      return; // Programa finalizado
    }

    final Tuple t = instrucciones[estado.lineaActual];

    // Registrar línea ejecutada
    estado.registrarLinea("Línea ${t.lineaID}");

    // Ejecutar según tipo
    if (t is AssignTuple) {
      _ejecutarAsignacion(t);
    } else if (t is ReadTuple) {
      _ejecutarLeer(t);
    } else if (t is WriteTuple) {
      _ejecutarEscribir(t);
    } else if (t is CompareTuple) {
      _ejecutarComparacion(t);
      return; // Ya manejó el salto de flujo
    } else if (t is EndTuple) {
      estado.registrarSalida("Fin del programa.");
      estado.lineaActual = instrucciones.length;
      return;
    }

    estado.lineaActual++;
  }

  /// ----------------------------------------------------
  /// ASIGNACIÓN
  /// ----------------------------------------------------
  void _ejecutarAsignacion(AssignTuple t) {
    final valor = _evaluarExpresion(t.expresion);
    tablaSimbolos.actualizar(t.variable, valor);

    estado.registrarSalida("${t.variable} = $valor");
    estado.registrarEstadoVariables(tablaSimbolos.mapaVariables);
  }

  /// ----------------------------------------------------
  /// LEER VARIABLE (solicita input)
  /// En esta versión: creamos una entrada dummy "0"
  /// En Fase 3 UI: se reemplaza por un modal interactivo
  /// ----------------------------------------------------
  void _ejecutarLeer(ReadTuple t) {
    final dummy = 0;
    tablaSimbolos.actualizar(t.variable, dummy);

    estado.registrarSalida("Leer ${t.variable} -> $dummy");
    estado.registrarEstadoVariables(tablaSimbolos.mapaVariables);
  }

  /// ----------------------------------------------------
  /// ESCRIBIR
  /// ----------------------------------------------------
  void _ejecutarEscribir(WriteTuple t) {
    final valor = _evaluarExpresion(t.valor);
    estado.registrarSalida(valor.toString());
  }

  /// ----------------------------------------------------
  /// COMPARACIÓN (Si ... Entonces ...)
  /// ----------------------------------------------------
  void _ejecutarComparacion(CompareTuple t) {
    final resultado = _evaluarComparacion(t);

    if (resultado) {
      estado.lineaActual = t.saltoVerdadero ?? estado.lineaActual + 1;
    } else {
      estado.lineaActual = t.saltoFalso ?? estado.lineaActual + 1;
    }
  }

  /// ----------------------------------------------------
  /// EVALUAR COMPARACIÓN
  /// ----------------------------------------------------
  bool _evaluarComparacion(CompareTuple t) {
    final izquierda = _evaluarExpresion(t.izquierda);
    final derecha = _evaluarExpresion(t.derecha);

    switch (t.operador) {
      case ">":
        return izquierda > derecha;
      case "<":
        return izquierda < derecha;
      case ">=":
        return izquierda >= derecha;
      case "<=":
        return izquierda <= derecha;
      case "==":
        return izquierda == derecha;
      case "!=":
        return izquierda != derecha;
    }

    return false;
  }

  /// ----------------------------------------------------
  /// EVALUAR EXPRESIÓN (como en PseudoInterprete.java)
  /// ----------------------------------------------------
  dynamic _evaluarExpresion(List<Token>? expr) {
    if (expr == null || expr.isEmpty) return null;

    // Caso literal simple
    if (expr.length == 1) {
      return _resolverValor(expr.first);
    }

    // Convertir a lista de valores
    List<dynamic> valores = expr.map(_resolverValor).toList();

    // Evaluar operación simple: a + b, a - b, etc.
    if (valores.length == 3) {
      final izquierda = valores[0];
      final op = expr[1].lexema;
      final derecha = valores[2];

      return _operar(izquierda, op, derecha);
    }

    return valores.first;
  }

  /// ----------------------------------------------------
  /// OPERAR ARITMÉTICAMENTE
  /// ----------------------------------------------------
  dynamic _operar(dynamic a, String op, dynamic b) {
    switch (op) {
      case "+":
        return a + b;
      case "-":
        return a - b;
      case "*":
        return a * b;
      case "/":
        return a / b;
      default:
        return null;
    }
  }

  /// ----------------------------------------------------
  /// RESOLVER VALOR: número, texto o variable
  /// ----------------------------------------------------
  dynamic _resolverValor(Token t) {
    if (t.tipo == TipoToken.numero) {
      return num.parse(t.lexema);
    }

    if (t.tipo == TipoToken.texto) {
      return t.lexema.replaceAll('"', "");
    }

    if (t.tipo == TipoToken.identificador) {
      return tablaSimbolos.obtener(t.lexema)?.valor;
    }

    return t.lexema;
  }

  /// ----------------------------------------------------
  /// Reiniciar todo
  /// ----------------------------------------------------
  void reset() {
    estado.reset();
    tablaSimbolos.limpiar();
  }
}
