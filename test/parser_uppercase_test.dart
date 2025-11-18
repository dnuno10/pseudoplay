import 'package:flutter_test/flutter_test.dart';

import 'package:pseudoplay/managers/lexer_manager.dart';
import 'package:pseudoplay/managers/parser_manager.dart';

void main() {
  test('parser acepta FUNCION en mayúsculas y FinFuncion mezclado', () {
    const codigo = '''
INICIO
FUNCION saludar(nombre)
  ESCRIBIR "Hola", nombre
FinFuncion
LLAMAR saludar("Axel")
FIN
''';

    final lexer = LexerManager();
    final parser = ParserManager();

    final tokens = lexer.analizar(codigo);

    expect(() => parser.validarSintaxis(tokens), returnsNormally);
    expect(() => parser.parsear(tokens), returnsNormally);
  });
}
