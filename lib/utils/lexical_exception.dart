class LexicalException implements Exception {
  final String message;
  final int line;
  final int column;

  LexicalException(this.message, this.line, this.column);

  @override
  String toString() {
    return "Error léxico en línea $line, columna $column: $message";
  }
}
