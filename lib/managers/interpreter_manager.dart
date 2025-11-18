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

    // NO registrar línea en consola

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
    } else if (t is FunctionEntryTuple) {
      _ejecutarFunctionEntry(t);
      return; // Ya manejó el salto de flujo
    } else if (t is FunctionEndTuple) {
      _ejecutarFunctionEnd(t);
      return; // Ya manejó el salto de flujo
    } else if (t is FunctionCallTuple) {
      _ejecutarFunctionCall(t);
      return; // Ya manejó el salto de flujo
    } else if (t is EndTuple) {
      // NO registrar en consola, solo en desk check
      estado.registrarPaso(
        linea: "Línea ${t.lineaID}",
        variables: tablaSimbolos.mapaVariables,
        operacion: 'FIN',
        variable: '',
        valorNuevo: '',
      );
      estado.lineaActual = instrucciones.length;
      return;
    }

    estado.lineaActual++;
  }

  /// ----------------------------------------------------
  /// ASIGNACIÓN
  /// ----------------------------------------------------
  void _ejecutarAsignacion(AssignTuple t) {
    print(
      '[ASIGNACIÓN] Variable: ${t.variable}, lineaActual: ${estado.lineaActual}',
    );
    final valor = _evaluarExpresion(t.expresion);
    print('[ASIGNACIÓN] Valor evaluado: $valor');
    tablaSimbolos.actualizar(t.variable, valor);
    print('[ASIGNACIÓN] Tabla después: ${tablaSimbolos.mapaVariables}');

    // NO registrar en consola, solo en paso de escritorio
    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'ASIGNAR',
      variable: t.variable,
      valorNuevo: valor?.toString() ?? '',
    );
  }

  /// ----------------------------------------------------
  /// LEER VARIABLE (solicita input)
  /// El valor ya debe estar en la tabla de símbolos (asignado por execution_controller)
  /// Este método solo registra el paso
  /// ----------------------------------------------------
  void _ejecutarLeer(ReadTuple t) {
    // Obtener el valor actual de la variable (ya asignado por continuarConInput)
    final simbolo = tablaSimbolos.obtener(t.variable);
    final valor = simbolo?.valor ?? 0;

    print('[LEER] Variable: ${t.variable}, Valor actual en tabla: $valor');
    print('[LEER] Tabla completa: ${tablaSimbolos.mapaVariables}');

    // NO registrar en consola, solo en paso de escritorio
    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'LEER',
      variable: t.variable,
      valorNuevo: valor.toString(),
    );
  }

  /// ----------------------------------------------------
  /// ESCRIBIR
  /// ----------------------------------------------------
  void _ejecutarEscribir(WriteTuple t) {
    final salida = _evaluarSalida(t.valor);
    estado.registrarSalida(salida);
    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'ESCRIBIR',
      variable: '',
      valorNuevo: salida,
    );
  }

  String _evaluarSalida(List<Token>? expr) {
    if (expr == null || expr.isEmpty) return '';

    final partes = <String>[];
    final buffer = <Token>[];

    void flushBuffer() {
      if (buffer.isEmpty) return;
      final valor = _evaluarExpresion(buffer);
      partes.add(valor?.toString() ?? '');
      buffer.clear();
    }

    for (final token in expr) {
      if (token.tipo == TipoToken.coma) {
        flushBuffer();
      } else {
        buffer.add(token);
      }
    }

    flushBuffer();

    return partes.join(' ').trimRight();
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

    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'CONDICIÓN',
      variable: '',
      valorNuevo: resultado ? 'VERDADERO' : 'FALSO',
    );
  }

  /// ----------------------------------------------------
  /// ENTRADA A FUNCIÓN
  /// ----------------------------------------------------
  void _ejecutarFunctionEntry(FunctionEntryTuple t) {
    // Saltar al final de la función (no ejecutarla hasta que sea llamada)
    estado.lineaActual = t.saltoVerdadero ?? estado.lineaActual + 1;

    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'DEFINIR FUNCIÓN',
      variable: t.nombre,
      valorNuevo: '',
    );
  }

  /// ----------------------------------------------------
  /// FIN DE FUNCIÓN
  /// ----------------------------------------------------
  void _ejecutarFunctionEnd(FunctionEndTuple t) {
    // Retornar al punto después de la llamada
    // (esto será manejado por la pila de llamadas)
    estado.lineaActual++;

    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'FIN FUNCIÓN',
      variable: t.nombre,
      valorNuevo: '',
    );
  }

  /// ----------------------------------------------------
  /// LLAMADA A FUNCIÓN
  /// ----------------------------------------------------
  void _ejecutarFunctionCall(FunctionCallTuple t) {
    // Buscar la función en las instrucciones
    int funcionInicio = -1;
    int funcionFin = -1;
    FunctionEntryTuple? definicion;

    for (int i = 0; i < instrucciones.length; i++) {
      final inst = instrucciones[i];
      if (inst is FunctionEntryTuple && inst.nombre == t.nombre) {
        definicion = inst;
        funcionInicio = i + 1; // Después de FunctionEntry
        funcionFin = inst.saltoVerdadero ?? instrucciones.length;
        break;
      }
    }

    if (funcionInicio == -1 || definicion == null) {
      // Función no encontrada
      estado.lineaActual++;
      return;
    }

    final parametros = definicion.parametros;
    final valoresArgumentos = t.argumentos
        .map((argumento) => _evaluarExpresion(argumento))
        .toList();

    if (valoresArgumentos.length != parametros.length) {
      print(
        '[FUNCIÓN CALL] Advertencia: ${t.nombre} recibió ${valoresArgumentos.length} argumentos, pero espera ${parametros.length}',
      );
    }

    final valoresPrevios = <String, dynamic>{};
    final nuevosParametros = <String>{};

    for (var i = 0; i < parametros.length; i++) {
      final nombreParametro = parametros[i];
      if (tablaSimbolos.existe(nombreParametro)) {
        valoresPrevios[nombreParametro] = tablaSimbolos
            .obtener(nombreParametro)
            ?.valor;
      } else {
        nuevosParametros.add(nombreParametro);
      }

      final valorAsignado = i < valoresArgumentos.length
          ? valoresArgumentos[i]
          : null;
      tablaSimbolos.actualizar(nombreParametro, valorAsignado);
    }

    // Guardar el punto de retorno
    final puntoRetorno = estado.lineaActual + 1;

    print('[FUNCIÓN CALL] Llamando a ${t.nombre}');
    print('[FUNCIÓN CALL] Variables antes: ${tablaSimbolos.mapaVariables}');
    print('[FUNCIÓN CALL] Inicio: $funcionInicio, Fin: $funcionFin');

    // Ejecutar el cuerpo de la función
    estado.lineaActual = funcionInicio;

    // Ejecutar instrucciones hasta FunctionEnd
    while (estado.lineaActual < funcionFin) {
      final inst = instrucciones[estado.lineaActual];

      if (inst is FunctionEndTuple) {
        break;
      }

      print(
        '[FUNCIÓN] Ejecutando instrucción en línea ${estado.lineaActual}: ${inst.runtimeType}',
      );

      // Ejecutar la instrucción actual
      if (inst is AssignTuple) {
        print('[FUNCIÓN] Asignando ${inst.variable} = ${inst.expresion}');
        _ejecutarAsignacion(inst);
        print('[FUNCIÓN] Después de asignar: ${tablaSimbolos.mapaVariables}');
        estado.lineaActual++;
      } else if (inst is ReadTuple) {
        _ejecutarLeer(inst);
        estado.lineaActual++;
      } else if (inst is WriteTuple) {
        _ejecutarEscribir(inst);
        estado.lineaActual++;
      } else if (inst is CompareTuple) {
        _ejecutarComparacion(inst);
        // No incrementar, _ejecutarComparacion ya maneja el salto
      } else if (inst is FunctionCallTuple) {
        // Llamada recursiva a función
        _ejecutarFunctionCall(inst);
        // No incrementar, _ejecutarFunctionCall ya maneja el salto
      } else {
        estado.lineaActual++;
      }
    }

    // Retornar al punto después de la llamada
    estado.lineaActual = puntoRetorno;

    for (final nombreParametro in parametros.reversed) {
      if (nuevosParametros.contains(nombreParametro)) {
        tablaSimbolos.eliminar(nombreParametro);
      } else {
        tablaSimbolos.actualizar(
          nombreParametro,
          valoresPrevios[nombreParametro],
        );
      }
    }

    print('[FUNCIÓN CALL] Variables después: ${tablaSimbolos.mapaVariables}');
    print('[FUNCIÓN CALL] Retornando a línea: $puntoRetorno');

    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'LLAMAR',
      variable: t.nombre,
      valorNuevo: '',
    );
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

    print('[EVALUAR] Expresión: ${expr.map((t) => t.lexema).join(" ")}');

    // Caso literal simple
    if (expr.length == 1) {
      final valor = _resolverValor(expr.first);
      print('[EVALUAR] Valor simple: $valor');
      return valor;
    }

    // Convertir a lista de valores
    List<dynamic> valores = expr.map(_resolverValor).toList();
    print('[EVALUAR] Valores resueltos: $valores');

    // Evaluar operación simple: a + b, a - b, etc.
    if (valores.length == 3) {
      final izquierda = valores[0];
      final op = expr[1].lexema;
      final derecha = valores[2];

      print('[EVALUAR] Operación: $izquierda $op $derecha');
      final resultado = _operar(izquierda, op, derecha);
      print('[EVALUAR] Resultado: $resultado');
      return resultado;
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

    if (t.tipo == TipoToken.texto || t.tipo == TipoToken.cadena) {
      return t.lexema.replaceAll('"', "");
    }

    if (t.tipo == TipoToken.identificador) {
      final simbolo = tablaSimbolos.obtener(t.lexema);
      final valor = simbolo?.valor ?? 0;
      print(
        '[RESOLVER] Variable ${t.lexema} = $valor (símbolo: ${simbolo != null ? "existe" : "NO EXISTE"})',
      );
      return valor; // Retornar 0 en lugar de null
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
