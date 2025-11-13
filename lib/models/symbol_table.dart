import 'symbol.dart';

class SymbolTable {
  final Map<String, Symbol> _tabla = {};

  bool existe(String nombre) => _tabla.containsKey(nombre);

  void agregar(Symbol simbolo) {
    _tabla[simbolo.nombre] = simbolo;
  }

  Symbol? obtener(String nombre) => _tabla[nombre];

  void actualizar(String nombre, dynamic valor) {
    if (_tabla.containsKey(nombre)) {
      _tabla[nombre]!.valor = valor;
    }
  }

  void limpiar() => _tabla.clear();

  Map<String, dynamic> get mapaVariables => {
    for (var e in _tabla.entries) e.key: e.value.valor,
  };

  @override
  String toString() => _tabla.toString();
}
