import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/block_model.dart';

final blocksManagerProvider = NotifierProvider<BlocksManager, List<BlockModel>>(
  BlocksManager.new,
);

class BlocksManager extends Notifier<List<BlockModel>> {
  @override
  List<BlockModel> build() => [];

  void agregarBloque(
    String tipo,
    String display, {
    Map<String, dynamic>? data,
  }) {
    state = [...state, BlockModel(tipo: tipo, display: display, data: data)];
  }

  void eliminarBloque(int index) {
    if (index < 0 || index >= state.length) return;
    final updated = [...state]..removeAt(index);
    state = updated;
  }

  void reset() {
    state = [];
  }

  String convertirAPseudocodigo() {
    final buffer = StringBuffer();
    int nivelIndentacion = 1;

    buffer.writeln("INICIO");

    for (final b in state) {
      final indentacion = "  " * nivelIndentacion;

      switch (b.tipo) {
        case "variable":
          buffer.writeln(
            "$indentacion${b.data!['nombre']} = ${b.data!['valor']}",
          );
          break;

        case "asignacion":
          buffer.writeln("$indentacion${b.data!['var']} = ${b.data!['expr']}");
          break;

        case "leer":
          buffer.writeln("${indentacion}LEER ${b.data!['var']}");
          break;

        case "escribir":
          buffer.writeln("${indentacion}ESCRIBIR ${b.data!['valor']}");
          break;

        case "si":
          buffer.writeln("${indentacion}SI ${b.data!['condicion']} ENTONCES");
          nivelIndentacion++;
          break;

        case "sino":
          nivelIndentacion--;
          buffer.writeln("${indentacion}SINO");
          nivelIndentacion++;
          break;

        case "finsi":
          nivelIndentacion--;
          buffer.writeln("${indentacion}FINSI");
          break;

        case "repite":
          buffer.writeln("${indentacion}REPITE");
          nivelIndentacion++;
          break;

        case "finrepite":
          nivelIndentacion--;
          final veces = b.data!['veces'] ?? '';
          if (veces.toString().isNotEmpty) {
            buffer.writeln("${indentacion}HASTA ${veces}");
          }
          buffer.writeln("${indentacion}FINREPITE");
          break;
      }
    }

    buffer.writeln("FIN");

    return buffer.toString();
  }
}
