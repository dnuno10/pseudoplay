class SyntaxException implements Exception {
  final String message;
  final int line;

  SyntaxException(this.message, this.line);

  @override
  String toString() {
    return "Error de sintaxis en línea $line: $message";
  }
}
