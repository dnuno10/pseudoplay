import 'symbol.dart';
import 'variable_type.dart';

class SymbolTable {
  final Map<String, Symbol> _tabla = {};

  bool existe(String nombre) => _tabla.containsKey(nombre);

  void agregar(Symbol simbolo) {
    _tabla[simbolo.nombre] = simbolo;
  }

  Symbol? obtener(String nombre) => _tabla[nombre];

  Symbol asegurar(String nombre, {VariableType tipo = VariableType.numero}) {
    return _tabla.putIfAbsent(
      nombre,
      () => Symbol(nombre: nombre, tipo: tipo, valor: null),
    );
  }

  void actualizar(
    String nombre,
    dynamic valor, {
    VariableType tipo = VariableType.numero,
  }) {
    final simbolo = asegurar(nombre, tipo: tipo);
    simbolo.valor = valor;
  }

  void limpiar() => _tabla.clear();

  void eliminar(String nombre) => _tabla.remove(nombre);

  Map<String, dynamic> get mapaVariables => {
    for (var e in _tabla.entries) e.key: e.value.valor,
  };

  @override
  String toString() => _tabla.toString();
}
