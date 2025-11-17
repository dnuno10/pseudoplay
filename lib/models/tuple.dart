class Tuple {
  final int lineaID;
  int? saltoVerdadero;
  int? saltoFalso;

  Tuple({required this.lineaID, this.saltoVerdadero, this.saltoFalso});

  // Lógica se implementará en managers (InterpreterManager)
  void ejecutar(Map<String, dynamic> ctx) {}
}

class AssignTuple extends Tuple {
  final String variable;
  final dynamic expresion;

  AssignTuple({
    required super.lineaID,
    required this.variable,
    required this.expresion,
  });
}

class ReadTuple extends Tuple {
  final String variable;

  ReadTuple({required super.lineaID, required this.variable});
}

class WriteTuple extends Tuple {
  final dynamic valor;

  WriteTuple({required super.lineaID, required this.valor});
}

class CompareTuple extends Tuple {
  final dynamic izquierda;
  final String operador;
  final dynamic derecha;

  CompareTuple({
    required super.lineaID,
    required this.izquierda,
    required this.operador,
    required this.derecha,
  });
}

class EndTuple extends Tuple {
  EndTuple({required super.lineaID});
}

class FunctionEntryTuple extends Tuple {
  final String nombre;

  FunctionEntryTuple({
    required super.lineaID,
    required this.nombre,
    int? saltoFin,
  }) : super(saltoVerdadero: saltoFin);
}

class FunctionEndTuple extends Tuple {
  final String nombre;

  FunctionEndTuple({required super.lineaID, required this.nombre});
}

class FunctionCallTuple extends Tuple {
  final String nombre;

  FunctionCallTuple({required super.lineaID, required this.nombre});
}
