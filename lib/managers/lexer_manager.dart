import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/token.dart';
import '../models/tipo_token.dart';
import '../utils/lexical_exception.dart';

final lexerManagerProvider = Provider((ref) => LexerManager());

class LexerManager {
  LexerManager();

  final List<String> palabrasReservadas = [
    "Si",
    "Entonces",
    "Sino",
    "FinSi",
    "Repite",
    "FinRepite",
    "Leer",
    "Escribir",
    "Funcion",
    "FinFuncion",
    "Llamar",
    "Fin",
    "FinPrograma",
    "INICIO",
    "VARIABLE",
    "LEER",
    "ESCRIBIR",
    "FIN",
    "inicio-programa",
    "leer",
    "escribir",
    "fin-programa",
    "mientras",
    "fin-mientras",
    "Mientras",
    "FinMientras",
    "MIENTRAS",
    "FINMIENTRAS",
    "HACER",
    "hacer",
    "Hacer",
  ];

  final List<String> comparadores = ["==", ">=", "<=", "!=", ">", "<"];

  final List<String> operadores = ["+", "-", "*", "/", "%"];

  late final Set<String> _palabrasReservadasNormalized = {
    for (final palabra in palabrasReservadas) palabra.toUpperCase(),
  };

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

      if (c == '/' && i + 1 < codigo.length && codigo[i + 1] == '/') {
        agregarTokenDesdeBuffer();
        while (i < codigo.length && codigo[i] != '\n') {
          i++;
          columna++;
        }
        i--;
        continue;
      }

      if (c == '"') {
        agregarTokenDesdeBuffer();
        String cadena = '"';
        int inicio = columna;
        i++;
        columna++;

        while (i < codigo.length && codigo[i] != '"') {
          if (codigo[i] == '\n') {
            linea++;
            columna = 1;
          } else {
            columna++;
          }
          cadena += codigo[i];
          i++;
        }

        if (i < codigo.length) {
          cadena += '"';
          columna++;
        }

        tokens.add(
          Token(
            lexema: cadena,
            tipo: TipoToken.cadena,
            linea: linea,
            columna: inicio,
          ),
        );
        continue;
      }

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

      if (c.trim().isEmpty) {
        agregarTokenDesdeBuffer();
        columna++;
        continue;
      }

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
          i++;
          columna += 2;
          continue;
        }
      }

      if (["(", ")", "[", "]", "{", "}", ",", "="].contains(c)) {
        agregarTokenDesdeBuffer();

        TipoToken tipo = TipoToken.desconocido;
        if (c == "(" || c == "[" || c == "{") {
          tipo = TipoToken.parentesisApertura;
        }
        if (c == ")" || c == "]" || c == "}") {
          tipo = TipoToken.parentesisCierre;
        }
        if (c == ",") tipo = TipoToken.coma;
        if (c == "=") tipo = TipoToken.asignacion;

        tokens.add(
          Token(lexema: c, tipo: tipo, linea: linea, columna: columna),
        );
        columna++;
        continue;
      }

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

      buffer += c;
      columna++;
    }

    agregarTokenDesdeBuffer();

    return tokens;
  }

  TipoToken _clasificar(String lexema) {
    if (_palabrasReservadasNormalized.contains(lexema.toUpperCase())) {
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

    if (lexema.startsWith('"') && lexema.endsWith('"')) {
      return TipoToken.texto;
    }

    final isIdent = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ_][a-zA-ZáéíóúÁÉÍÓÚñÑ0-9_]*$");
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
