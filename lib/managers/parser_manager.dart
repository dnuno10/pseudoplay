import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/token.dart';
import '../models/tipo_token.dart';
import '../models/tuple.dart';
import '../utils/syntax_exception.dart';

final parserManagerProvider = Provider((ref) => ParserManager());

class ParserManager {
  int _indice = 0;
  List<Token> _tokens = [];

  Token get actual => _tokens[_indice];
  bool get fin => _indice >= _tokens.length;

  void avanzar() {
    if (!fin) _indice++;
  }

  bool _es(TipoToken tipo) {
    if (fin) return false;
    return actual.tipo == tipo;
  }

  bool _lexema(String s) {
    if (fin) return false;
    return actual.lexema == s;
  }

  /// ---------------------------------------------
  /// MÉTODO PRINCIPAL → PARSEAR
  /// ---------------------------------------------
  List<Tuple> parsear(List<Token> tokens) {
    _tokens = tokens;
    _indice = 0;

    List<Tuple> instrucciones = [];

    while (!fin) {
      final t = _parseInstruccion();
      if (t != null) instrucciones.add(t);

      avanzar(); // mover al siguiente token
    }

    return instrucciones;
  }

  /// ---------------------------------------------
  /// DETERMINA QUÉ TIPO DE INSTRUCCIÓN ES
  /// ---------------------------------------------
  Tuple? _parseInstruccion() {
    if (fin) return null;

    // Estructuras condicionales
    if (_lexema("Si")) {
      return _parseSi();
    }

    // Bucle Repite
    if (_lexema("Repite")) {
      return _parseRepite();
    }

    // Leer variable → Leer x
    if (_lexema("Leer")) {
      return _parseLeer();
    }

    // Escribir → Escribir x
    if (_lexema("Escribir")) {
      return _parseEscribir();
    }

    // Asignación → x = 5
    if (_es(TipoToken.identificador)) {
      return _parseAsignacion();
    }

    return null;
  }

  /// ----------------------------------------------------
  /// PARSEAR ASIGNACIÓN:  variable = expresion
  /// ----------------------------------------------------
  Tuple _parseAsignacion() {
    Token varToken = actual;

    avanzar();

    if (!_lexema("=")) {
      throw SyntaxException("Se esperaba '='", varToken.linea);
    }

    avanzar();

    // Aquí recogeremos todo lo que sigue hasta fin de línea
    List<Token> expr = [];

    while (!fin && !_es(TipoToken.finLinea)) {
      expr.add(actual);
      avanzar();
    }

    return AssignTuple(
      lineaID: varToken.linea,
      variable: varToken.lexema,
      expresion: expr,
    );
  }

  /// ----------------------------------------------------
  /// PARSEAR LEER:   Leer variable
  /// ----------------------------------------------------
  Tuple _parseLeer() {
    Token inicio = actual;

    avanzar();

    if (!_es(TipoToken.identificador)) {
      throw SyntaxException(
        "Se esperaba una variable después de Leer",
        inicio.linea,
      );
    }

    String varName = actual.lexema;

    return ReadTuple(lineaID: inicio.linea, variable: varName);
  }

  /// ----------------------------------------------------
  /// PARSEAR ESCRIBIR:   Escribir valor
  /// ----------------------------------------------------
  Tuple _parseEscribir() {
    Token inicio = actual;

    avanzar();

    List<Token> expr = [];

    while (!fin && !_es(TipoToken.finLinea)) {
      expr.add(actual);
      avanzar();
    }

    return WriteTuple(lineaID: inicio.linea, valor: expr);
  }

  /// ----------------------------------------------------
  /// PARSEAR SI - ENTONCES - SINO - FINSI
  /// ----------------------------------------------------
  Tuple _parseSi() {
    Token inicio = actual;

    avanzar();

    // Leer condición
    List<Token> condicion = [];

    while (!fin && !_lexema("Entonces")) {
      condicion.add(actual);
      avanzar();
    }

    if (!_lexema("Entonces")) {
      throw SyntaxException("Se esperaba 'Entonces'", inicio.linea);
    }

    // Aquí no generamos tuplas internas; eso lo hará el generador.
    return CompareTuple(
      lineaID: inicio.linea,
      izquierda: condicion, // se interpretará luego
      operador: "", // se procesará luego
      derecha: null,
    );
  }

  /// ----------------------------------------------------
  /// PARSEAR REPITE ... FINREPITE
  /// ----------------------------------------------------
  Tuple _parseRepite() {
    Token inicio = actual;

    // No procesa lógica aquí, el Generador lo hará
    return Tuple(lineaID: inicio.linea);
  }

  /// ----------------------------------------------------
  /// VALIDACIÓN RÁPIDA DE SINTAXIS
  /// ----------------------------------------------------
  void validarSintaxis(List<Token> tokens) {
    int si = 0;
    int repite = 0;

    for (var t in tokens) {
      if (t.lexema == "Si") si++;
      if (t.lexema == "FinSi") si--;
      if (t.lexema == "Repite") repite++;
      if (t.lexema == "FinRepite") repite--;

      if (si < 0 || repite < 0) {
        throw SyntaxException(
          "FinSi o FinRepite sin bloque de inicio",
          t.linea,
        );
      }
    }

    if (si != 0) {
      throw SyntaxException("Bloque 'Si' incompleto", tokens.last.linea);
    }
    if (repite != 0) {
      throw SyntaxException("Bloque 'Repite' incompleto", tokens.last.linea);
    }
  }
}
