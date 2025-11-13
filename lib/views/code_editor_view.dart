import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../provider/editor_provider.dart';
import '../managers/execution_controller.dart';
import '../utils/dialog_utils.dart';

class CodeEditorView extends ConsumerWidget {
  const CodeEditorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.watch(editorProvider));

    return Scaffold(
      appBar: AppBar(
        title: Text("Editor de pseudocódigo", style: AppTextStyles.title),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/algorithms'),
            icon: const Icon(Icons.menu_book_outlined, color: AppColors.purple),
          ),
        ],
      ),
      body: Column(
        children: [
          // ------------------------------------------------------
          // EDITOR VISUAL
          // ------------------------------------------------------
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.codeBackground,
              child: TextField(
                controller: controller,
                maxLines: null,
                onChanged: (value) =>
                    ref.read(editorProvider.notifier).updateText(value),
                decoration: const InputDecoration(
                  hintText: "Escribe tu pseudocódigo aquí...",
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontFamily: "IBM Plex Mono",
                  fontSize: 15,
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // BOTÓN EJECUTAR
          // ------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: () {
                final codigo = ref.read(editorProvider);

                ref
                    .read(executionControllerProvider.notifier)
                    .procesarCodigo(codigo);

                final execState = ref.read(executionControllerProvider);

                if (execState.error != null) {
                  DialogUtils.mostrarError(context, execState.error!);
                  return;
                }

                Navigator.pushNamed(context, '/execution');
              },
              child: Text(
                "Ejecutar",
                style: AppTextStyles.subtitle.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
