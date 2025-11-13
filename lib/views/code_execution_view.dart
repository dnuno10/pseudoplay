import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/source_code_provider.dart';
import '../managers/execution_controller.dart';
import '../managers/interpreter_manager.dart';
import '../provider/variables_provider.dart';
import '../provider/console_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../components/pp_console.dart';
import '../components/variable_viewer.dart';

class CodeExecutionView extends ConsumerStatefulWidget {
  const CodeExecutionView({super.key});

  @override
  ConsumerState<CodeExecutionView> createState() => _CodeExecutionViewState();
}

class _CodeExecutionViewState extends ConsumerState<CodeExecutionView> {
  final ScrollController _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final lineas = ref.watch(sourceCodeProvider);
    final consola = ref.watch(consoleProvider);
    final variables = ref.watch(variablesProvider);
    final interprete = ref.watch(interpreterManagerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          (interprete.estado.lineaActual * 40).toDouble(),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Ejecución paso a paso", style: AppTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.purple),
            onPressed: () {
              ref.read(executionControllerProvider.notifier).reiniciar();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // ----------------------
          // CÓDIGO CON RESALTADO
          // ----------------------
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.codeBackground,
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: lineas.length,
                itemBuilder: (_, i) {
                  final isCurrent = interprete.estado.lineaActual == i;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isCurrent
                          ? AppColors.purple.withValues(alpha: 0.15)
                          : Colors.transparent,
                    ),
                    child: Text(
                      lineas[i],
                      style: AppTextStyles.code.copyWith(
                        color: isCurrent
                            ? AppColors.purple
                            : AppColors.textDark,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ----------------------
          // CONSOLA + VARIABLES
          // ----------------------
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(flex: 2, child: PPConsole(output: consola)),
                Expanded(child: VariableViewer(variables: variables)),
              ],
            ),
          ),
        ],
      ),

      // ----------------------
      // BOTONES
      // ----------------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ref.read(executionControllerProvider.notifier).ejecutarPaso();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Siguiente paso",
                  style: AppTextStyles.small.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/deskcheck'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Prueba de escritorio",
                  style: AppTextStyles.small.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
