import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/token.dart';
import '../models/tipo_token.dart';
import '../models/tuple.dart';
import '../utils/syntax_exception.dart';

final parserManagerProvider = Provider((ref) => ParserManager());

class ParserManager {
  late List<Token> _tokens;
  int _indice = 0;
  final List<_FunctionBlock> _funcionesPendientes = [];

  Token get _actual => _tokens[_indice];
  bool get _fin => _indice >= _tokens.length;
  bool get _actualEsFinLinea => !_fin && _actual.tipo == TipoToken.finLinea;
  int get _lineaActual =>
      _tokens.isEmpty ? 0 : (_fin ? _tokens.last.linea : _actual.linea);

  List<Tuple> parsear(List<Token> tokens) {
    _tokens = tokens;
    _indice = 0;
    _funcionesPendientes.clear();

    final instrucciones = <Tuple>[];

    while (true) {
      _saltarSeparadores();
      if (_fin) break;

      if (_esLexema("INICIO") || _esLexema("inicio-programa")) {
        _avanzar();
        continue;
      }

      if (_esLexema("FIN") ||
          _esLexema("Fin") ||
          _esLexema("FinPrograma") ||
          _esLexema("fin-programa")) {
        instrucciones.add(_parseFinPrograma());
        continue;
      }

      if (_esLexema("VARIABLE")) {
        instrucciones.add(_parseVariable());
        continue;
      }

      if (_esLexema("LEER") || _esLexema("Leer") || _esLexema("leer")) {
        instrucciones.add(_parseLeer());
        continue;
      }

      if (_esLexema("ESCRIBIR") ||
          _esLexema("Escribir") ||
          _esLexema("escribir")) {
        instrucciones.add(_parseEscribir());
        continue;
      }

      if (_esLexema("Si")) {
        instrucciones.add(_parseSi());
        continue;
      }

      if (_esLexema("Sino")) {
        instrucciones.add(_parseSino());
        continue;
      }

      if (_esLexema("FinSi")) {
        instrucciones.add(_parseFinSi());
        continue;
      }

      if (_esLexema("Repite") ||
          _esLexema("mientras") ||
          _esLexema("Mientras") ||
          _esLexema("MIENTRAS")) {
        instrucciones.add(_parseRepite());
        continue;
      }

      if (_esLexema("FinRepite") ||
          _esLexema("fin-mientras") ||
          _esLexema("FinMientras") ||
          _esLexema("FINMIENTRAS")) {
        instrucciones.add(_parseFinRepite());
        continue;
      }

      if (_esLexema("Funcion")) {
        instrucciones.add(_parseFuncion());
        continue;
      }

      if (_esLexema("FinFuncion")) {
        instrucciones.add(_parseFinFuncion());
        continue;
      }

      if (_esLexema("Llamar")) {
        instrucciones.add(_parseLlamarFuncion());
        continue;
      }

      if (_esTipoActual(TipoToken.identificador)) {
        if (_peekTipo(TipoToken.asignacion)) {
          instrucciones.add(_parseAsignacion());
          continue;
        }

        if (_peekTipo(TipoToken.parentesisApertura)) {
          instrucciones.add(_parseLlamadoInline());
          continue;
        }
      }

      throw SyntaxException(
        "Instrucción no reconocida: '${_actual.lexema}'",
        _actual.linea,
      );
    }

    if (_funcionesPendientes.isNotEmpty) {
      final bloque = _funcionesPendientes.last;
      throw SyntaxException(
        "Bloque de función '${bloque.nombre}' incompleto",
        bloque.linea,
      );
    }

    return instrucciones;
  }

  AssignTuple _parseAsignacion() {
    final variable = _actual;
    _avanzar();

    _consumirTipo(
      TipoToken.asignacion,
      "Se esperaba '=' después de ${variable.lexema}",
    );

    final expresion = _capturarHastaFinLinea();

    return AssignTuple(
      lineaID: variable.linea,
      variable: variable.lexema,
      expresion: expresion,
    );
  }

  AssignTuple _parseVariable() {
    final inicio = _actual;
    _avanzar();

    if (_fin || !_esTipoActual(TipoToken.identificador)) {
      throw SyntaxException(
        "Se esperaba un nombre de variable después de VARIABLE",
        inicio.linea,
      );
    }

    final variable = _actual;
    _avanzar();

    _consumirTipo(
      TipoToken.asignacion,
      "Se esperaba '=' después de ${variable.lexema}",
    );

    final expresion = _capturarHastaFinLinea();

    return AssignTuple(
      lineaID: variable.linea,
      variable: variable.lexema,
      expresion: expresion,
    );
  }

  ReadTuple _parseLeer() {
    final inicio = _actual;
    _avanzar();

    if (_fin || !_esTipoActual(TipoToken.identificador)) {
      throw SyntaxException(
        "Se esperaba una variable después de ${inicio.lexema}",
        inicio.linea,
      );
    }

    final nombre = _actual.lexema;
    _avanzar();

    return ReadTuple(lineaID: inicio.linea, variable: nombre);
  }

  WriteTuple _parseEscribir() {
    final inicio = _actual;
    _avanzar();
    final expr = _capturarHastaFinLinea();

    return WriteTuple(lineaID: inicio.linea, valor: expr);
  }

  CompareTuple _parseSi() {
    final inicio = _consumirLexema("Si");
    final condicion = _capturarHastaLexema("Entonces");
    _consumirLexema("Entonces");

    final comparadorIdx = condicion.indexWhere(
      (token) => token.tipo == TipoToken.comparador,
    );

    if (comparadorIdx == -1) {
      throw SyntaxException(
        "La condición de 'Si' requiere un comparador",
        inicio.linea,
      );
    }

    final izquierda = condicion.sublist(0, comparadorIdx);
    final derecha = condicion.sublist(comparadorIdx + 1);

    if (izquierda.isEmpty || derecha.isEmpty) {
      throw SyntaxException(
        "La condición de 'Si' debe tener dos expresiones",
        inicio.linea,
      );
    }

    return CompareTuple(
      lineaID: inicio.linea,
      izquierda: List<Token>.from(izquierda),
      operador: condicion[comparadorIdx].lexema,
      derecha: List<Token>.from(derecha),
    );
  }

  Tuple _parseSino() {
    final token = _consumirLexema("Sino");
    return Tuple(lineaID: -1000, saltoVerdadero: token.linea);
  }

  Tuple _parseFinSi() {
    final token = _consumirLexema("FinSi");
    return Tuple(lineaID: -2000, saltoVerdadero: token.linea);
  }

  Tuple _parseRepite() {
    Token inicio;
    bool esMientras = false;

    if (_esLexema("Repite")) {
      inicio = _consumirLexema("Repite");
    } else if (_esLexema("mientras")) {
      inicio = _consumirLexema("mientras");
      esMientras = true;
    } else if (_esLexema("Mientras")) {
      inicio = _consumirLexema("Mientras");
      esMientras = true;
    } else if (_esLexema("MIENTRAS")) {
      inicio = _consumirLexema("MIENTRAS");
      esMientras = true;
    } else {
      throw SyntaxException("Se esperaba MIENTRAS o REPITE", _lineaActual);
    }

    if (esMientras) {
      final condicion = _capturarHastaLexema("HACER");

      if (_esLexema("HACER") || _esLexema("hacer") || _esLexema("Hacer")) {
        _consumirLexema(_actual.lexema);
      }

      final comparadorIdx = condicion.indexWhere(
        (token) => token.tipo == TipoToken.comparador,
      );

      if (comparadorIdx == -1) {
        throw SyntaxException(
          "La condición de 'MIENTRAS' requiere un comparador",
          inicio.linea,
        );
      }

      final izquierda = condicion.sublist(0, comparadorIdx);
      final derecha = condicion.sublist(comparadorIdx + 1);

      if (izquierda.isEmpty || derecha.isEmpty) {
        throw SyntaxException(
          "La condición de 'MIENTRAS' debe tener dos expresiones",
          inicio.linea,
        );
      }

      return CompareTuple(
        lineaID: -5000,
        izquierda: List<Token>.from(izquierda),
        operador: condicion[comparadorIdx].lexema,
        derecha: List<Token>.from(derecha),
      );
    }

    return Tuple(lineaID: -3000);
  }

  Tuple _parseFinRepite() {
    if (_esLexema("FinRepite")) {
      _consumirLexema("FinRepite");
    } else if (_esLexema("fin-mientras")) {
      _consumirLexema("fin-mientras");
    } else if (_esLexema("FinMientras")) {
      _consumirLexema("FinMientras");
    } else if (_esLexema("FINMIENTRAS")) {
      _consumirLexema("FINMIENTRAS");
    }
    return Tuple(lineaID: -4000);
  }

  FunctionEntryTuple _parseFuncion() {
    final inicio = _consumirLexema("Funcion");

    if (_fin || !_esTipoActual(TipoToken.identificador)) {
      throw SyntaxException(
        "Se esperaba el nombre de la función",
        inicio.linea,
      );
    }

    final nombre = _actual.lexema;
    final linea = inicio.linea;
    _avanzar();

    var parametros = <String>[];
    if (!_fin && _esTipoActual(TipoToken.parentesisApertura)) {
      _avanzar();
      parametros = _parseParameterList();
    }

    _funcionesPendientes.add(_FunctionBlock(nombre: nombre, linea: linea));

    return FunctionEntryTuple(
      lineaID: linea,
      nombre: nombre,
      parametros: parametros,
    );
  }

  FunctionEndTuple _parseFinFuncion() {
    final token = _consumirLexema("FinFuncion");

    if (_funcionesPendientes.isEmpty) {
      throw SyntaxException("FinFuncion sin Funcion", token.linea);
    }

    final bloque = _funcionesPendientes.removeLast();
    return FunctionEndTuple(lineaID: token.linea, nombre: bloque.nombre);
  }

  FunctionCallTuple _parseLlamarFuncion() {
    final inicio = _consumirLexema("Llamar");

    if (_fin || !_esTipoActual(TipoToken.identificador)) {
      throw SyntaxException(
        "Se esperaba el nombre de la función a invocar",
        inicio.linea,
      );
    }

    final nombre = _actual.lexema;
    final linea = inicio.linea;
    _avanzar();

    var argumentos = <List<Token>>[];
    if (!_fin && _esTipoActual(TipoToken.parentesisApertura)) {
      _avanzar();
      argumentos = _parseArgumentList();
    }

    return FunctionCallTuple(
      lineaID: linea,
      nombre: nombre,
      argumentos: argumentos,
    );
  }

  FunctionCallTuple _parseLlamadoInline() {
    final nombre = _actual.lexema;
    final linea = _actual.linea;
    _avanzar();

    _consumirTipo(
      TipoToken.parentesisApertura,
      "Se esperaba '(' para invocar $nombre",
    );
    final argumentos = _parseArgumentList();

    return FunctionCallTuple(
      lineaID: linea,
      nombre: nombre,
      argumentos: argumentos,
    );
  }

  EndTuple _parseFinPrograma() {
    final token = _actual;
    _avanzar();
    return EndTuple(lineaID: token.linea);
  }

  void validarSintaxis(List<Token> tokens) {
    final pila = <_Bloque>[];

    for (final token in tokens) {
      final lexema = _normalizeLexema(token.lexema);
      switch (lexema) {
        case "SI":
          pila.add(_Bloque(tipo: _BloqueTipo.si));
          break;
        case "SINO":
          if (pila.isEmpty || pila.last.tipo != _BloqueTipo.si) {
            throw SyntaxException("Sino sin bloque Si", token.linea);
          }
          if (pila.last.tieneSino) {
            throw SyntaxException("El bloque Si ya tiene un Sino", token.linea);
          }
          pila.last.tieneSino = true;
          break;
        case "FINSI":
          _cerrarBloque(pila, _BloqueTipo.si, token);
          break;
        case "REPITE":
        case "MIENTRAS":
          pila.add(_Bloque(tipo: _BloqueTipo.repite));
          break;
        case "FINREPITE":
        case "FIN-MIENTRAS":
        case "FINMIENTRAS":
          _cerrarBloque(pila, _BloqueTipo.repite, token);
          break;
        case "FUNCION":
          pila.add(_Bloque(tipo: _BloqueTipo.funcion));
          break;
        case "FINFUNCION":
          _cerrarBloque(pila, _BloqueTipo.funcion, token);
          break;
      }
    }

    if (pila.isNotEmpty) {
      final bloque = pila.last;
      throw SyntaxException(
        "Bloque '${bloque.tipo.nombre}' incompleto",
        tokens.isEmpty ? 0 : tokens.last.linea,
      );
    }
  }

  void _cerrarBloque(List<_Bloque> pila, _BloqueTipo tipo, Token token) {
    if (pila.isEmpty || pila.last.tipo != tipo) {
      throw SyntaxException("Fin${tipo.nombre} sin apertura", token.linea);
    }
    pila.removeLast();
  }

  void _saltarSeparadores() {
    while (!_fin && _actualEsFinLinea) {
      _avanzar();
    }
  }

  void _avanzar() {
    if (!_fin) _indice++;
  }

  bool _esLexema(String lexema) =>
      !_fin && _normalizeLexema(_actual.lexema) == _normalizeLexema(lexema);

  bool _esTipoActual(TipoToken tipo) => !_fin && _actual.tipo == tipo;

  bool _peekTipo(TipoToken tipo, {int offset = 1}) {
    final idx = _indice + offset;
    if (idx >= _tokens.length) return false;
    return _tokens[idx].tipo == tipo;
  }

  Token _consumirLexema(String lexema) {
    if (!_esLexema(lexema)) {
      throw SyntaxException(
        "Se esperaba '${_normalizeLexema(lexema)}'",
        _lineaActual,
      );
    }
    final token = _actual;
    _avanzar();
    return token;
  }

  Token _consumirTipo(TipoToken tipo, String mensaje) {
    if (!_esTipoActual(tipo)) {
      throw SyntaxException(mensaje, _lineaActual);
    }
    final token = _actual;
    _avanzar();
    return token;
  }

  List<Token> _capturarHastaFinLinea({bool permitirVacio = false}) {
    final expr = <Token>[];

    while (!_fin && !_actualEsFinLinea) {
      expr.add(_actual);
      _avanzar();
    }

    if (expr.isEmpty && !permitirVacio) {
      throw SyntaxException("Se esperaba una expresión", _lineaActual);
    }

    return List<Token>.from(expr);
  }

  List<Token> _capturarHastaLexema(String lexema) {
    final resultado = <Token>[];

    while (!_fin && !_esLexema(lexema)) {
      if (_actualEsFinLinea) {
        throw SyntaxException(
          "Se esperaba '${_normalizeLexema(lexema)}'",
          _lineaActual,
        );
      }
      resultado.add(_actual);
      _avanzar();
    }

    if (_fin) {
      throw SyntaxException(
        "Se esperaba '${_normalizeLexema(lexema)}'",
        _lineaActual,
      );
    }

    return List<Token>.from(resultado);
  }

  List<String> _parseParameterList() {
    final parametros = <String>[];
    var esperandoIdentificador = true;
    var cerroParentesis = false;

    while (!_fin) {
      if (_esTipoActual(TipoToken.parentesisCierre)) {
        cerroParentesis = true;
        _avanzar();
        break;
      }

      if (_actualEsFinLinea) {
        throw SyntaxException(
          "Los parámetros deben cerrar en la misma línea",
          _lineaActual,
        );
      }

      if (esperandoIdentificador) {
        if (_esTipoActual(TipoToken.identificador)) {
          parametros.add(_actual.lexema);
          _avanzar();
          esperandoIdentificador = false;
          continue;
        }
        throw SyntaxException(
          "Se esperaba un nombre de parámetro",
          _lineaActual,
        );
      }

      if (_esTipoActual(TipoToken.coma)) {
        _avanzar();
        esperandoIdentificador = true;
        continue;
      }

      throw SyntaxException("Se esperaba ',' entre parámetros", _lineaActual);
    }

    if (!cerroParentesis) {
      throw SyntaxException("Se esperaba cierre de paréntesis", _lineaActual);
    }

    if (esperandoIdentificador && parametros.isNotEmpty) {
      throw SyntaxException("Falta nombre de parámetro", _lineaActual);
    }

    return parametros;
  }

  List<List<Token>> _parseArgumentList() {
    final argumentos = <List<Token>>[];
    final acumulado = <Token>[];
    var profundidad = 1;

    while (!_fin && profundidad > 0) {
      if (_esTipoActual(TipoToken.parentesisApertura)) {
        acumulado.add(_actual);
        profundidad++;
        _avanzar();
        continue;
      }

      if (_esTipoActual(TipoToken.parentesisCierre)) {
        profundidad--;
        if (profundidad == 0) {
          if (acumulado.isNotEmpty) {
            argumentos.add(List<Token>.from(acumulado));
            acumulado.clear();
          }
          _avanzar();
          break;
        }
        acumulado.add(_actual);
        _avanzar();
        continue;
      }

      if (_esTipoActual(TipoToken.coma) && profundidad == 1) {
        argumentos.add(List<Token>.from(acumulado));
        acumulado.clear();
        _avanzar();
        continue;
      }

      acumulado.add(_actual);
      _avanzar();
    }

    if (profundidad != 0) {
      throw SyntaxException("Se esperaba cierre de paréntesis", _lineaActual);
    }

    return argumentos;
  }

  String _normalizeLexema(String lexema) => lexema.trim().toUpperCase();
}

class _FunctionBlock {
  final String nombre;
  final int linea;

  _FunctionBlock({required this.nombre, required this.linea});
}

class _Bloque {
  final _BloqueTipo tipo;
  bool tieneSino;

  _Bloque({required this.tipo}) : tieneSino = false;
}

enum _BloqueTipo { si, repite, funcion }

extension on _BloqueTipo {
  String get nombre {
    switch (this) {
      case _BloqueTipo.si:
        return "Si";
      case _BloqueTipo.repite:
        return "Repite";
      case _BloqueTipo.funcion:
        return "Funcion";
    }
  }
}
