import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../managers/blocks_manager.dart';
import '../utils/block_dialogs.dart';
import '../provider/editor_provider.dart';

class BlocksModeView extends ConsumerWidget {
  const BlocksModeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bloques = ref.watch(blocksManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Modo por bloques", style: AppTextStyles.title),
      ),
      body: Row(
        children: [
          // -------------------------------------------------
          // COLUMNA IZQUIERDA: BLOQUES DISPONIBLES
          // -------------------------------------------------
          Container(
            width: 140,
            color: AppColors.codeBackground,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text("Bloques", style: AppTextStyles.subtitle),
                const SizedBox(height: 16),
                _menuButton(context, ref, "Variable"),
                _menuButton(context, ref, "Asignación"),
                _menuButton(context, ref, "Leer"),
                _menuButton(context, ref, "Escribir"),
                _menuButton(context, ref, "Si"),
                _menuButton(context, ref, "Sino"),
                _menuButton(context, ref, "FinSi"),
                _menuButton(context, ref, "Repite"),
                _menuButton(context, ref, "FinRepite"),
              ],
            ),
          ),

          // -------------------------------------------------
          // ÁREA DE BLOQUES
          // -------------------------------------------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final b in bloques)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${b.tipo.toUpperCase()} => ${b.data}",
                      style: AppTextStyles.small.copyWith(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // -------------------------------------------------
      // BOTONES INFERIORES
      // -------------------------------------------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            "Convertir a pseudocódigo",
            style: AppTextStyles.subtitle.copyWith(color: Colors.white),
          ),
          onPressed: () {
            final texto = ref
                .read(blocksManagerProvider.notifier)
                .convertirAPseudocodigo();

            ref.read(editorProvider.notifier).updateText(texto);

            Navigator.pushNamed(context, '/editor');
          },
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, WidgetRef ref, String tipo) {
    return InkWell(
      onTap: () async {
        Map<String, dynamic>? data;

        switch (tipo.toLowerCase()) {
          case "variable":
            data = await BlockDialogs.pedirVariable(context);
            break;
          case "asignación":
            data = await BlockDialogs.pedirAsignacion(context);
            break;
          case "leer":
            data = await BlockDialogs.pedirLeer(context);
            break;
          case "escribir":
            data = await BlockDialogs.pedirEscribir(context);
            break;
          case "si":
            data = await BlockDialogs.pedirCondicion(context);
            break;
          default:
            data = {};
        }

        if (data != null) {
          ref
              .read(blocksManagerProvider.notifier)
              .agregarBloque(tipo.toLowerCase(), data: data);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.purple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          tipo,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
