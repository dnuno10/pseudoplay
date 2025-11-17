class ProgramState {
  int lineaActual = 0;

  final List<String> consola = [];
  final List<ProgramStep> pasos = [];

  void registrarSalida(String texto) {
    consola.add(texto);
  }

  void registrarLinea(String texto) {
    consola.add(texto);
  }

  void registrarEstadoVariables(Map<String, dynamic> variables) {
    registrarPaso(
      linea: "Línea $lineaActual",
      variables: variables,
      operacion: 'ESTADO',
    );
  }

  void registrarPaso({
    required String linea,
    required Map<String, dynamic> variables,
    String operacion = '',
    String variable = '',
    String valorNuevo = '',
    String? salida,
  }) {
    pasos.add(
      ProgramStep(
        linea: linea,
        variables: {...variables},
        operacion: operacion,
        variable: variable,
        valorNuevo: valorNuevo,
        salida: salida ?? "",
      ),
    );
  }

  List<Map<String, dynamic>> get historialVariables {
    return pasos.map((paso) => paso.variables).toList();
  }

  ProgramSnapshot snapshot(Map<String, dynamic> variables) {
    return ProgramSnapshot(
      lineaActual: lineaActual,
      consola: List.unmodifiable(consola),
      variables: Map.unmodifiable(variables),
      pasos: List.unmodifiable(pasos),
    );
  }

  void reset() {
    lineaActual = 0;
    consola.clear();
    pasos.clear();
  }
}

class ProgramStep {
  final String linea;
  final Map<String, dynamic> variables;
  final String operacion;
  final String variable;
  final String valorNuevo;
  final String salida;

  const ProgramStep({
    required this.linea,
    required this.variables,
    required this.operacion,
    required this.variable,
    required this.valorNuevo,
    required this.salida,
  });
}

class ProgramSnapshot {
  final int lineaActual;
  final List<String> consola;
  final Map<String, dynamic> variables;
  final List<ProgramStep> pasos;

  const ProgramSnapshot({
    required this.lineaActual,
    required this.consola,
    required this.variables,
    required this.pasos,
  });
}
