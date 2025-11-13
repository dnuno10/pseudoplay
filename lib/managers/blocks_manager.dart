import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/block_model.dart';

final blocksManagerProvider = NotifierProvider<BlocksManager, List<BlockModel>>(
  BlocksManager.new,
);

class BlocksManager extends Notifier<List<BlockModel>> {
  @override
  List<BlockModel> build() => [];

  /// Agregar bloque básico
  void agregarBloque(String tipo, {Map<String, dynamic>? data}) {
    state = [...state, BlockModel(tipo: tipo, data: data)];
  }

  void reset() {
    state = [];
  }

  /// ----------------------------------------
  /// CONVERTIR BLOQUES → PSEUDOCÓDIGO COMPLETO
  /// ----------------------------------------
  String convertirAPseudocodigo() {
    final buffer = StringBuffer();

    for (final b in state) {
      switch (b.tipo) {
        case "variable":
          buffer.writeln("${b.data!['nombre']} = ${b.data!['valor']}");
          break;

        case "asignacion":
          buffer.writeln("${b.data!['var']} = ${b.data!['expr']}");
          break;

        case "leer":
          buffer.writeln("Leer ${b.data!['var']}");
          break;

        case "escribir":
          buffer.writeln("Escribir ${b.data!['valor']}");
          break;

        case "si":
          buffer.writeln("Si ${b.data!['condicion']} Entonces");
          break;

        case "sino":
          buffer.writeln("Sino");
          break;

        case "finsi":
          buffer.writeln("FinSi");
          break;

        case "repite":
          buffer.writeln("Repite");
          break;

        case "finrepite":
          buffer.writeln("FinRepite");
          break;
      }
    }

    return buffer.toString();
  }
}
