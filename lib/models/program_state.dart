class ProgramState {
  int lineaActual = 0;

  final List<String> consola = [];
  final List<Map<String, dynamic>> historialVariables = [];
  final List<String> historialLineas = [];
  final List<Map<String, dynamic>> historial = [];

  void registrarSalida(String texto) {
    consola.add(texto);
  }

  void registrarEstadoVariables(Map<String, dynamic> vars) {
    historialVariables.add({...vars});
  }

  void registrarLinea(String linea) {
    historialLineas.add(linea);
  }

  void registrarPaso({
    required String linea,
    required Map<String, dynamic> variables,
    String? salida,
  }) {
    historial.add({
      "linea": linea,
      "variables": {...variables},
      "salida": salida ?? "",
    });
  }

  void reset() {
    lineaActual = 0;
    consola.clear();
    historialVariables.clear();
    historialLineas.clear();
  }
}
