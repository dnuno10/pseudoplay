import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../managers/interpreter_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DeskCheckView extends ConsumerWidget {
  const DeskCheckView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interpreter = ref.watch(interpreterManagerProvider);

    final historial = interpreter.estado.historial;

    return Scaffold(
      appBar: AppBar(
        title: Text("Prueba de escritorio", style: AppTextStyles.title),
      ),
      body: historial.isEmpty
          ? Center(
              child: Text(
                "Aún no hay datos.\nEjecuta el algoritmo paso a paso.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.purple, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildTable(historial),
              ),
            ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> historial) {
    // Obtener todas las variables usadas
    final variables = {
      for (var paso in historial) ...paso["variables"].keys,
    }.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text("Línea", style: AppTextStyles.small)),
          DataColumn(label: Text("Salida", style: AppTextStyles.small)),
          ...variables.map(
            (v) => DataColumn(label: Text(v, style: AppTextStyles.small)),
          ),
        ],
        rows: historial.map((fila) {
          final linea = fila["linea"];
          final salida = fila["salida"];
          final vars = fila["variables"] as Map<String, dynamic>;

          return DataRow(
            cells: [
              DataCell(Text(linea, style: AppTextStyles.small)),
              DataCell(Text(salida, style: AppTextStyles.small)),
              ...variables.map(
                (v) => DataCell(
                  Text(vars[v]?.toString() ?? "", style: AppTextStyles.small),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
