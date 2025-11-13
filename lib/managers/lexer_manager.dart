import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/token.dart';
import '../models/tipo_token.dart';
import '../utils/lexical_exception.dart';

final lexerManagerProvider = Provider((ref) => LexerManager());

class LexerManager {
  LexerManager();

  // Palabras reservadas del pseudocódigo
  final List<String> palabrasReservadas = [
    "Si",
    "Entonces",
    "Sino",
    "FinSi",
    "Repite",
    "FinRepite",
    "Leer",
    "Escribir",
  ];

  final List<String> comparadores = ["==", ">=", "<=", "!=", ">", "<"];

  final List<String> operadores = ["+", "-", "*", "/"];

  /// ------------------------------------------
  /// MÉTODO PRINCIPAL → ANALIZAR CÓDIGO
  /// ------------------------------------------
  List<Token> analizar(String codigo) {
    List<Token> tokens = [];

    int linea = 1;
    int columna = 1;

    String buffer = "";

    void agregarTokenDesdeBuffer() {
      if (buffer.isEmpty) return;

      tokens.add(_crearToken(buffer, linea, columna - buffer.length));
      buffer = "";
    }

    for (int i = 0; i < codigo.length; i++) {
      String c = codigo[i];

      // Saltos de línea
      if (c == "\n") {
        agregarTokenDesdeBuffer();
        tokens.add(
          Token(
            lexema: ";",
            tipo: TipoToken.finLinea,
            linea: linea,
            columna: columna,
          ),
        );
        linea++;
        columna = 1;
        continue;
      }

      // Espacios → Separan tokens
      if (c.trim().isEmpty) {
        agregarTokenDesdeBuffer();
        columna++;
        continue;
      }

      // Comparadores de 2 caracteres
      if (i + 1 < codigo.length) {
        String dos = c + codigo[i + 1];
        if (comparadores.contains(dos)) {
          agregarTokenDesdeBuffer();
          tokens.add(
            Token(
              lexema: dos,
              tipo: TipoToken.comparador,
              linea: linea,
              columna: columna,
            ),
          );
          i++; // saltar el siguiente char
          columna += 2;
          continue;
        }
      }

      // Caracteres especiales simples
      if (["(", ")", ",", "="].contains(c)) {
        agregarTokenDesdeBuffer();

        TipoToken tipo = TipoToken.desconocido;
        if (c == "(") tipo = TipoToken.parentesisApertura;
        if (c == ")") tipo = TipoToken.parentesisCierre;
        if (c == ",") tipo = TipoToken.coma;
        if (c == "=") tipo = TipoToken.asignacion;

        tokens.add(
          Token(lexema: c, tipo: tipo, linea: linea, columna: columna),
        );
        columna++;
        continue;
      }

      // Operadores aritméticos
      if (operadores.contains(c)) {
        agregarTokenDesdeBuffer();
        tokens.add(
          Token(
            lexema: c,
            tipo: TipoToken.operador,
            linea: linea,
            columna: columna,
          ),
        );
        columna++;
        continue;
      }

      // Si es parte de un token → acumular en buffer
      buffer += c;
      columna++;
    }

    // Agregar último token acumulado
    agregarTokenDesdeBuffer();

    return tokens;
  }

  /// ------------------------------------------
  /// CLASIFICAR TOKEN (versión Dart del Java)
  /// ------------------------------------------
  TipoToken _clasificar(String lexema) {
    if (palabrasReservadas.contains(lexema)) {
      return TipoToken.palabraReservada;
    }

    if (comparadores.contains(lexema)) {
      return TipoToken.comparador;
    }

    if (operadores.contains(lexema)) {
      return TipoToken.operador;
    }

    final num? numero = num.tryParse(lexema);
    if (numero != null) {
      return TipoToken.numero;
    }

    // TEXTO entre comillas
    if (lexema.startsWith('"') && lexema.endsWith('"')) {
      return TipoToken.texto;
    }

    final isIdent = RegExp(r"^[a-zA-Z_][a-zA-Z0-9_]*$");
    if (isIdent.hasMatch(lexema)) {
      return TipoToken.identificador;
    }

    return TipoToken.desconocido;
  }

  Token _crearToken(String lexema, int linea, int columna) {
    final tipo = _clasificar(lexema);

    if (tipo == TipoToken.desconocido) {
      throw LexicalException("Token no reconocido: '$lexema'", linea, columna);
    }

    return Token(lexema: lexema, tipo: tipo, linea: linea, columna: columna);
  }
}
