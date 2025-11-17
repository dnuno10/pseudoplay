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

  /// ---------------------------------------------
  /// MÉTODO PRINCIPAL → PARSEAR
  /// ---------------------------------------------
  List<Tuple> parsear(List<Token> tokens) {
    _tokens = tokens;
    _indice = 0;
    _funcionesPendientes.clear();

    final instrucciones = <Tuple>[];

    while (true) {
      _saltarSeparadores();
      if (_fin) break;

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

      if (_esLexema("Repite")) {
        instrucciones.add(_parseRepite());
        continue;
      }

      if (_esLexema("FinRepite")) {
        instrucciones.add(_parseFinRepite());
        continue;
      }

      if (_esLexema("Leer")) {
        instrucciones.add(_parseLeer());
        continue;
      }

      if (_esLexema("Escribir")) {
        instrucciones.add(_parseEscribir());
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

      if (_esLexema("Fin") || _esLexema("FinPrograma")) {
        instrucciones.add(_parseFinPrograma());
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

  /// ----------------------------------------------------
  /// PARSEAR ASIGNACIÓN:  variable = expresion
  /// ----------------------------------------------------
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

  /// ----------------------------------------------------
  /// PARSEAR LEER:   Leer variable
  /// ----------------------------------------------------
  ReadTuple _parseLeer() {
    final inicio = _consumirLexema("Leer");

    if (_fin || !_esTipoActual(TipoToken.identificador)) {
      throw SyntaxException(
        "Se esperaba una variable después de Leer",
        inicio.linea,
      );
    }

    final nombre = _actual.lexema;
    _avanzar();

    return ReadTuple(lineaID: inicio.linea, variable: nombre);
  }

  /// ----------------------------------------------------
  /// PARSEAR ESCRIBIR:   Escribir valor
  /// ----------------------------------------------------
  WriteTuple _parseEscribir() {
    final inicio = _consumirLexema("Escribir");
    final expr = _capturarHastaFinLinea();

    return WriteTuple(lineaID: inicio.linea, valor: expr);
  }

  /// ----------------------------------------------------
  /// PARSEAR SI - ENTONCES - SINO - FINSI
  /// ----------------------------------------------------
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
    _consumirLexema("Repite");
    return Tuple(lineaID: -3000);
  }

  Tuple _parseFinRepite() {
    _consumirLexema("FinRepite");
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

    if (!_fin && _esTipoActual(TipoToken.parentesisApertura)) {
      _avanzar();
      _descartarArgumentos();
    }

    _funcionesPendientes.add(_FunctionBlock(nombre: nombre, linea: linea));

    return FunctionEntryTuple(lineaID: linea, nombre: nombre);
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

    if (!_fin && _esTipoActual(TipoToken.parentesisApertura)) {
      _avanzar();
      _descartarArgumentos();
    }

    return FunctionCallTuple(lineaID: linea, nombre: nombre);
  }

  FunctionCallTuple _parseLlamadoInline() {
    final nombre = _actual.lexema;
    final linea = _actual.linea;
    _avanzar();

    _consumirTipo(
      TipoToken.parentesisApertura,
      "Se esperaba '(' para invocar $nombre",
    );
    _descartarArgumentos();

    return FunctionCallTuple(lineaID: linea, nombre: nombre);
  }

  EndTuple _parseFinPrograma() {
    final token = _actual;
    _avanzar();
    return EndTuple(lineaID: token.linea);
  }

  /// ----------------------------------------------------
  /// VALIDACIÓN RÁPIDA DE SINTAXIS
  /// ----------------------------------------------------
  void validarSintaxis(List<Token> tokens) {
    final pila = <_Bloque>[];

    for (final token in tokens) {
      switch (token.lexema) {
        case "Si":
          pila.add(_Bloque(tipo: _BloqueTipo.si));
          break;
        case "Sino":
          if (pila.isEmpty || pila.last.tipo != _BloqueTipo.si) {
            throw SyntaxException("Sino sin bloque Si", token.linea);
          }
          if (pila.last.tieneSino) {
            throw SyntaxException("El bloque Si ya tiene un Sino", token.linea);
          }
          pila.last.tieneSino = true;
          break;
        case "FinSi":
          _cerrarBloque(pila, _BloqueTipo.si, token);
          break;
        case "Repite":
          pila.add(_Bloque(tipo: _BloqueTipo.repite));
          break;
        case "FinRepite":
          _cerrarBloque(pila, _BloqueTipo.repite, token);
          break;
        case "Funcion":
          pila.add(_Bloque(tipo: _BloqueTipo.funcion));
          break;
        case "FinFuncion":
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

  // -----------------------------------------------------
  // Helpers internos
  // -----------------------------------------------------
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

  bool _esLexema(String lexema) => !_fin && _actual.lexema == lexema;

  bool _esTipoActual(TipoToken tipo) => !_fin && _actual.tipo == tipo;

  bool _peekTipo(TipoToken tipo, {int offset = 1}) {
    final idx = _indice + offset;
    if (idx >= _tokens.length) return false;
    return _tokens[idx].tipo == tipo;
  }

  Token _consumirLexema(String lexema) {
    if (!_esLexema(lexema)) {
      throw SyntaxException("Se esperaba '$lexema'", _lineaActual);
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
        throw SyntaxException("Se esperaba '$lexema'", _lineaActual);
      }
      resultado.add(_actual);
      _avanzar();
    }

    if (_fin) {
      throw SyntaxException("Se esperaba '$lexema'", _lineaActual);
    }

    return List<Token>.from(resultado);
  }

  void _descartarArgumentos() {
    int profundidad = 1;

    while (!_fin && profundidad > 0) {
      if (_actual.tipo == TipoToken.parentesisApertura) {
        profundidad++;
      } else if (_actual.tipo == TipoToken.parentesisCierre) {
        profundidad--;
      }
      _avanzar();
    }

    if (profundidad != 0) {
      throw SyntaxException("Se esperaba ')'", _lineaActual);
    }
  }
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
