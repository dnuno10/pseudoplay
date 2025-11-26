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

  void cargarPrograma(List<Tuple> tuplas) {
    instrucciones = tuplas;
    estado.reset();
  }

  void ejecutarPaso() {
    if (estado.lineaActual >= instrucciones.length) {
      return;
    }

    final Tuple t = instrucciones[estado.lineaActual];

    if (t is AssignTuple) {
      _ejecutarAsignacion(t);
    } else if (t is ReadTuple) {
      _ejecutarLeer(t);
    } else if (t is WriteTuple) {
      _ejecutarEscribir(t);
    } else if (t is CompareTuple) {
      _ejecutarComparacion(t);
      return;
    } else if (t is FunctionEntryTuple) {
      _ejecutarFunctionEntry(t);
      return;
    } else if (t is FunctionEndTuple) {
      _ejecutarFunctionEnd(t);
      return;
    } else if (t is FunctionCallTuple) {
      _ejecutarFunctionCall(t);
      return;
    } else if (t is EndTuple) {
      estado.registrarPaso(
        linea: "Línea ${t.lineaID}",
        variables: tablaSimbolos.mapaVariables,
        operacion: 'FIN',
        variable: '',
        valorNuevo: '',
      );
      estado.lineaActual = instrucciones.length;
      return;
    } else if (t.saltoVerdadero != null) {
      estado.lineaActual = t.saltoVerdadero!;
      return;
    }

    estado.lineaActual++;
  }

  void _ejecutarAsignacion(AssignTuple t) {
    print(
      '[ASIGNACIÓN] Variable: ${t.variable}, lineaActual: ${estado.lineaActual}',
    );
    final valor = _evaluarExpresion(t.expresion);
    print('[ASIGNACIÓN] Valor evaluado: $valor');
    tablaSimbolos.actualizar(t.variable, valor);
    print('[ASIGNACIÓN] Tabla después: ${tablaSimbolos.mapaVariables}');

    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'ASIGNAR',
      variable: t.variable,
      valorNuevo: valor?.toString() ?? '',
    );
  }

  void _ejecutarLeer(ReadTuple t) {
    final simbolo = tablaSimbolos.obtener(t.variable);
    final valor = simbolo?.valor ?? 0;

    print('[LEER] Variable: ${t.variable}, Valor actual en tabla: $valor');
    print('[LEER] Tabla completa: ${tablaSimbolos.mapaVariables}');

    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'LEER',
      variable: t.variable,
      valorNuevo: valor.toString(),
    );
  }

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

  void _ejecutarFunctionEntry(FunctionEntryTuple t) {
    estado.lineaActual = t.saltoVerdadero ?? estado.lineaActual + 1;

    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'DEFINIR FUNCIÓN',
      variable: t.nombre,
      valorNuevo: '',
    );
  }

  void _ejecutarFunctionEnd(FunctionEndTuple t) {
    estado.lineaActual++;

    estado.registrarPaso(
      linea: "Línea ${t.lineaID}",
      variables: tablaSimbolos.mapaVariables,
      operacion: 'FIN FUNCIÓN',
      variable: t.nombre,
      valorNuevo: '',
    );
  }

  void _ejecutarFunctionCall(FunctionCallTuple t) {
    int funcionInicio = -1;
    int funcionFin = -1;
    FunctionEntryTuple? definicion;

    for (int i = 0; i < instrucciones.length; i++) {
      final inst = instrucciones[i];
      if (inst is FunctionEntryTuple && inst.nombre == t.nombre) {
        definicion = inst;
        funcionInicio = i + 1;
        funcionFin = inst.saltoVerdadero ?? instrucciones.length;
        break;
      }
    }

    if (funcionInicio == -1 || definicion == null) {
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

    final puntoRetorno = estado.lineaActual + 1;

    print('[FUNCIÓN CALL] Llamando a ${t.nombre}');
    print('[FUNCIÓN CALL] Variables antes: ${tablaSimbolos.mapaVariables}');
    print('[FUNCIÓN CALL] Inicio: $funcionInicio, Fin: $funcionFin');

    estado.lineaActual = funcionInicio;

    while (estado.lineaActual < funcionFin) {
      final inst = instrucciones[estado.lineaActual];

      if (inst is FunctionEndTuple) {
        break;
      }

      print(
        '[FUNCIÓN] Ejecutando instrucción en línea ${estado.lineaActual}: ${inst.runtimeType}',
      );

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
      } else if (inst is FunctionCallTuple) {
        _ejecutarFunctionCall(inst);
      } else if (inst.saltoVerdadero != null) {
        estado.lineaActual = inst.saltoVerdadero!;
      } else {
        estado.lineaActual++;
      }
    }

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

  dynamic _evaluarExpresion(List<Token>? expr) {
    if (expr == null || expr.isEmpty) return null;

    print('[EVALUAR] Expresión: ${expr.map((t) => t.lexema).join(" ")}');

    if (expr.length == 1) {
      final valor = _resolverValor(expr.first);
      print('[EVALUAR] Valor simple: $valor');
      return valor;
    }

    List<Token> tokensConParentesisResueltos = _evaluarParentesis(expr);

    if (tokensConParentesisResueltos.length == 3) {
      final izquierda = _resolverValor(tokensConParentesisResueltos[0]);
      final op = tokensConParentesisResueltos[1].lexema;
      final derecha = _resolverValor(tokensConParentesisResueltos[2]);

      print('[EVALUAR] Operación: $izquierda $op $derecha');
      final resultado = _operar(izquierda, op, derecha);
      print('[EVALUAR] Resultado: $resultado');
      return resultado;
    }

    int i = 0;
    while (i < tokensConParentesisResueltos.length) {
      if (tokensConParentesisResueltos[i].lexema == '*' ||
          tokensConParentesisResueltos[i].lexema == '/' ||
          tokensConParentesisResueltos[i].lexema == '%') {
        if (i > 0 && i < tokensConParentesisResueltos.length - 1) {
          final izq = _resolverValor(tokensConParentesisResueltos[i - 1]);
          final op = tokensConParentesisResueltos[i].lexema;
          final der = _resolverValor(tokensConParentesisResueltos[i + 1]);

          final resultado = _operar(izq, op, der);
          print('[EVALUAR] Operación parcial: $izq $op $der = $resultado');

          tokensConParentesisResueltos.removeRange(i - 1, i + 2);
          tokensConParentesisResueltos.insert(
            i - 1,
            Token(
              tipo: TipoToken.numero,
              lexema: resultado.toString(),
              linea: 0,
              columna: 0,
            ),
          );
          i = 0;
        } else {
          i++;
        }
      } else {
        i++;
      }
    }

    i = 0;
    while (i < tokensConParentesisResueltos.length) {
      if (tokensConParentesisResueltos[i].lexema == '+' ||
          tokensConParentesisResueltos[i].lexema == '-') {
        if (i > 0 && i < tokensConParentesisResueltos.length - 1) {
          final izq = _resolverValor(tokensConParentesisResueltos[i - 1]);
          final op = tokensConParentesisResueltos[i].lexema;
          final der = _resolverValor(tokensConParentesisResueltos[i + 1]);

          final resultado = _operar(izq, op, der);
          print('[EVALUAR] Operación parcial: $izq $op $der = $resultado');

          tokensConParentesisResueltos.removeRange(i - 1, i + 2);
          tokensConParentesisResueltos.insert(
            i - 1,
            Token(
              tipo: TipoToken.numero,
              lexema: resultado.toString(),
              linea: 0,
              columna: 0,
            ),
          );
          i = 0;
        } else {
          i++;
        }
      } else {
        i++;
      }
    }

    final resultadoFinal = tokensConParentesisResueltos.isNotEmpty
        ? _resolverValor(tokensConParentesisResueltos.first)
        : null;
    print('[EVALUAR] Resultado final: $resultadoFinal');
    return resultadoFinal;
  }

  List<Token> _evaluarParentesis(List<Token> tokens) {
    int profundidadMax = 0;
    int profundidadActual = 0;
    int inicioParentesis = -1;
    int finParentesis = -1;

    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i].tipo == TipoToken.parentesisApertura) {
        profundidadActual++;
        if (profundidadActual > profundidadMax) {
          profundidadMax = profundidadActual;
          inicioParentesis = i;
        }
      } else if (tokens[i].tipo == TipoToken.parentesisCierre) {
        if (profundidadActual == profundidadMax && inicioParentesis != -1) {
          finParentesis = i;
          break;
        }
        profundidadActual--;
      }
    }

    if (inicioParentesis == -1 || finParentesis == -1) {
      return tokens;
    }

    final tokensInternos = tokens.sublist(inicioParentesis + 1, finParentesis);
    final resultadoInterno = _evaluarExpresion(tokensInternos);

    final tokenResultado = Token(
      tipo: TipoToken.numero,
      lexema: resultadoInterno.toString(),
      linea: 0,
      columna: 0,
    );

    final nuevosTokens = <Token>[
      ...tokens.sublist(0, inicioParentesis),
      tokenResultado,
      ...tokens.sublist(finParentesis + 1),
    ];

    return _evaluarParentesis(nuevosTokens);
  }

  dynamic _operar(dynamic a, String op, dynamic b) {
    num numA = a is num ? a : num.tryParse(a.toString()) ?? 0;
    num numB = b is num ? b : num.tryParse(b.toString()) ?? 0;

    switch (op) {
      case "+":
        return numA + numB;
      case "-":
        return numA - numB;
      case "*":
        return numA * numB;
      case "/":
        return numA / numB;
      case "%":
        return numA % numB;
      default:
        return null;
    }
  }

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
      return valor;
    }

    return t.lexema;
  }

  void reset() {
    estado.reset();
    tablaSimbolos.limpiar();
  }
}
