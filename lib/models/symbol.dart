import 'variable_type.dart';

class Symbol {
  final String nombre;
  final VariableType tipo;
  dynamic valor;

  Symbol({required this.nombre, required this.tipo, this.valor});

  @override
  String toString() => "$nombre ($tipo) = $valor";
}
