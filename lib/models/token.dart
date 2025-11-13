import 'tipo_token.dart';

class Token {
  final String lexema;
  final TipoToken tipo;
  final int linea;
  final int columna;

  Token({
    required this.lexema,
    required this.tipo,
    required this.linea,
    required this.columna,
  });

  @override
  String toString() => "$lexema ($tipo) [L:$linea C:$columna]";
}
