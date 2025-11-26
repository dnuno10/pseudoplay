import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/editor_provider.dart';
import '../provider/execution_speed_provider.dart';
import '../managers/execution_controller.dart';
import '../managers/interpreter_manager.dart';
import '../models/game_mode.dart';
import '../provider/user_preferences_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CodeExecutionView extends ConsumerStatefulWidget {
  const CodeExecutionView({super.key});

  @override
  ConsumerState<CodeExecutionView> createState() => _CodeExecutionViewState();
}

class _CodeExecutionViewState extends ConsumerState<CodeExecutionView>
    with TickerProviderStateMixin {
  late AnimationController _crtController;
  late AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();
  late final UserPreferencesNotifier _prefsNotifier;

  bool _isExecuting = false;
  bool _showScrollHint = false;

  @override
  void initState() {
    super.initState();

    _crtController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _prefsNotifier = ref.read(userPreferencesProvider.notifier);
    _prefsNotifier.startSession(GameMode.execution);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final codigo = ref.read(editorProvider);
        ref.read(executionControllerProvider.notifier).procesarCodigo(codigo);

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _startAutoExecution();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _prefsNotifier.stopSession(GameMode.execution);
    _crtController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      setState(() => _showScrollHint = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showScrollHint = false);
      });
    }
  }

  void _startAutoExecution() async {
    final speed = ref.read(executionSpeedProvider);
    if (speed == 0) return;

    setState(() => _isExecuting = true);

    while (_isExecuting && mounted) {
      final exec = ref.read(executionControllerProvider);
      final interprete = ref.read(interpreterManagerProvider);

      if (exec.esperandoInput) {
        await _mostrarDialogoLeer();
        continue;
      }

      if (exec.listo &&
          interprete.estado.lineaActual < interprete.instrucciones.length) {
        ref.read(executionControllerProvider.notifier).ejecutarPaso();
        final currentSpeed = ref.read(executionSpeedProvider);
        await Future.delayed(
          Duration(milliseconds: (currentSpeed * 1000).toInt()),
        );
      } else {
        if (!mounted) return;
        setState(() => _isExecuting = false);
        _scrollToBottom();
        break;
      }
    }
  }

  void _stopExecution() {
    setState(() => _isExecuting = false);
  }

  void _executeNextStep() async {
    ref.read(executionControllerProvider.notifier).ejecutarPaso();

    final exec = ref.read(executionControllerProvider);
    if (exec.esperandoInput) {
      await _mostrarDialogoLeer();
    }
  }

  void _executePreviousStep() {
    ref.read(executionControllerProvider.notifier).retrocederPaso();
  }

  Future<void> _mostrarDialogoLeer() async {
    final exec = ref.read(executionControllerProvider);
    if (!exec.esperandoInput || exec.variableInput == null) return;

    final controller = TextEditingController();

    final resultado = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.purple,
            border: Border.all(width: 4, color: Colors.black),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LEER ${exec.variableInput}',
                style: AppTextStyles.title.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: AppTextStyles.body.copyWith(fontSize: 18),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(width: 3, color: Colors.black),
                    borderRadius: BorderRadius.zero,
                  ),
                  hintText: 'Ingresa un número',
                  hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
                ),
                onSubmitted: (value) => Navigator.of(context).pop(value),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(controller.text),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    border: Border.all(width: 3, color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'CONFIRMAR',
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (resultado != null && resultado.isNotEmpty) {
      ref
          .read(executionControllerProvider.notifier)
          .continuarConInput(resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final codigo = ref.watch(editorProvider);
    final exec = ref.watch(executionControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RetroTexturePainter())),

          IgnorePointer(child: _buildScanlines(w, h)),

          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(w * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(w),
                  SizedBox(height: h * 0.02),
                  _buildControlButtons(w, h),
                  if (_isExecuting) ...[
                    SizedBox(height: h * 0.015),
                    _buildExecutingIndicator(w),
                  ],
                  SizedBox(height: h * 0.02),
                  _buildEditor(codigo, w, h),
                  SizedBox(height: h * 0.02),
                  _buildVariables(exec.variables, w, h),
                  SizedBox(height: h * 0.02),
                  _buildConsole(exec.consola, exec.error, w, h),

                  if (_haTerminado(exec)) ...[
                    SizedBox(height: h * 0.02),
                    _buildDeskCheckButton(w, h),
                  ],

                  SizedBox(height: h * 0.03),
                ],
              ),
            ),
          ),

          if (_showScrollHint) _buildScrollHint(w, h),
        ],
      ),
    );
  }

  Widget _buildHeader(double w) {
    return GestureDetector(
      onTap: () => context.go('/editor'),
      child: Row(
        children: [
          Icon(Icons.arrow_back_ios, size: w * 0.07, color: AppColors.purple),
          SizedBox(width: w * 0.02),
          Text(
            'Ejecución\nde pseudocódigo',
            style: AppTextStyles.title.copyWith(
              fontSize: w * 0.085,
              height: 1.1,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }

  bool _haTerminado(ExecutionState exec) {
    if (!exec.listo) return false;
    final interprete = ref.read(interpreterManagerProvider);
    return interprete.estado.lineaActual >= interprete.instrucciones.length;
  }

  Widget _buildDeskCheckButton(double w, double h) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/deskcheck'),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.08,
            vertical: h * 0.02,
          ),
          decoration: BoxDecoration(
            color: AppColors.green,
            border: Border.all(width: w * 0.008, color: Colors.black),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.table_chart, color: Colors.white, size: w * 0.06),
              SizedBox(width: w * 0.03),
              Text(
                'VER PRUEBA DE ESCRITORIO',
                style: AppTextStyles.subtitle.copyWith(
                  color: Colors.white,
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutingIndicator(double w) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        return Opacity(
          opacity: 0.5 + (_pulseController.value * 0.5),
          child: Row(
            children: [
              Container(
                width: w * 0.03,
                height: w * 0.03,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C851),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: w * 0.02),
              Text(
                'Ejecutando...',
                style: AppTextStyles.code.copyWith(
                  fontSize: w * 0.035,
                  color: const Color(0xFF00C851),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(double w, double h) {
    final speed = ref.watch(executionSpeedProvider);
    final exec = ref.watch(executionControllerProvider);
    final interprete = ref.read(interpreterManagerProvider);
    final haEmpezado =
        exec.lineaActual > 0 || interprete.estado.lineaActual > 0;

    return Row(
      children: [
        if (speed == 0) ...[
          _retroButton(
            w,
            h,
            color: const Color(0xFF2962FF),
            icon: Icons.skip_previous,
            label: 'ANTERIOR',
            onTap: _executePreviousStep,
          ),
          SizedBox(width: w * 0.02),
          _retroButton(
            w,
            h,
            color: const Color(0xFF2962FF),
            icon: Icons.skip_next,
            label: 'SIGUIENTE',
            onTap: _executeNextStep,
          ),
          SizedBox(width: w * 0.02),
          _retroButton(
            w,
            h,
            color: AppColors.orange,
            icon: Icons.refresh,
            onTap: () {
              _stopExecution();
              ref.read(executionControllerProvider.notifier).reiniciar();
            },
          ),
        ] else ...[
          if (!haEmpezado && !_isExecuting) ...[
            _retroButton(
              w,
              h,
              color: const Color(0xFF00C851),
              icon: Icons.play_arrow,
              label: 'EJECUTAR',
              onTap: _startAutoExecution,
            ),
            SizedBox(width: w * 0.02),
          ] else if (_isExecuting) ...[
            _retroButton(
              w,
              h,
              color: AppColors.orange,
              icon: Icons.pause,
              label: 'PAUSAR',
              onTap: _stopExecution,
            ),
            SizedBox(width: w * 0.02),
          ],
          if (haEmpezado) ...[
            _retroButton(
              w,
              h,
              color: AppColors.orange,
              icon: Icons.refresh,
              label: 'REINICIAR',
              onTap: () {
                _stopExecution();
                ref.read(executionControllerProvider.notifier).reiniciar();
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _retroButton(
    double w,
    double h, {
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    String? label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.02),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(width: w * 0.008, color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: label != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: w * 0.06),
                  SizedBox(width: w * 0.02),
                  Text(
                    label,
                    style: AppTextStyles.code.copyWith(
                      fontSize: w * 0.035,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Icon(icon, color: Colors.white, size: w * 0.09),
      ),
    );
  }

  Widget _buildEditor(String code, double w, double h) {
    final lines = code.isEmpty
        ? ["// Escribe tu pseudocódigo aquí", "INICIO..."]
        : code.split('\n');

    final execState = ref.watch(executionControllerProvider);
    final interprete = ref.watch(interpreterManagerProvider);

    int currentLineNumber = -1;
    int lineOffset = 0;
    if (execState.tuplas.isNotEmpty) {
      final firstLine = execState.tuplas.first.lineaID;
      if (firstLine > 1) {
        lineOffset = firstLine - 1;
      }
    }

    if (execState.listo &&
        interprete.estado.lineaActual < interprete.instrucciones.length) {
      final tuplaActual =
          interprete.instrucciones[interprete.estado.lineaActual];
      final adjustedLine = tuplaActual.lineaID - lineOffset;
      currentLineNumber = adjustedLine.clamp(1, lines.length).toInt();
    }

    return Container(
      constraints: BoxConstraints(minHeight: h * 0.15, maxHeight: h * 0.35),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        border: Border.all(width: w * 0.009, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(lines.length, (index) {
                final lineNum = index + 1;
                final isCurrentLine = lineNum == currentLineNumber;
                return Container(
                  height: 20,
                  padding: EdgeInsets.only(right: w * 0.03),
                  color: isCurrentLine
                      ? const Color(0xFF00C851).withOpacity(0.3)
                      : Colors.transparent,
                  child: Text(
                    '$lineNum',
                    style: AppTextStyles.code.copyWith(
                      fontSize: w * 0.035,
                      height: 1.3,
                      color: isCurrentLine
                          ? const Color(0xFF00FFAA)
                          : const Color(0xFF666666),
                      fontWeight: isCurrentLine
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(lines.length, (index) {
                  final lineNum = index + 1;
                  final isCurrentLine = lineNum == currentLineNumber;
                  return Container(
                    height: 20,
                    color: isCurrentLine
                        ? const Color(0xFF00C851).withOpacity(0.3)
                        : Colors.transparent,
                    child: Text(
                      lines[index],
                      style: AppTextStyles.code.copyWith(
                        fontSize: w * 0.035,
                        height: 1.3,
                        color: const Color(0xFF00FFAA),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariables(Map<String, dynamic> vars, double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.purple,
        border: Border.all(width: w * 0.009, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variables en tiempo real',
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.045,
              color: Colors.white,
            ),
          ),
          SizedBox(height: h * 0.015),
          if (vars.isEmpty)
            Text(
              "No hay variables",
              style: AppTextStyles.code.copyWith(color: Colors.white70),
            ),
          ...vars.entries.map((e) => _variableItem(e.key, e.value, w, h)),
        ],
      ),
    );
  }

  Widget _variableItem(String name, dynamic value, double w, double h) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.01),
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        border: Border.all(width: w * 0.006, color: Colors.black),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.038,
              color: Colors.white,
            ),
          ),
          Text(
            value.toString(),
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.038,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsole(List<String> output, String? error, double w, double h) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: h * 0.15, maxHeight: h * 0.35),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF142A18),
        border: Border.all(width: w * 0.009, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Salida del programa:",
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.042,
              color: const Color(0xFF00FF8A),
            ),
          ),
          SizedBox(height: h * 0.015),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (error != null)
                    Container(
                      padding: EdgeInsets.all(w * 0.03),
                      margin: EdgeInsets.only(bottom: h * 0.015),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(.12),
                        border: Border.all(
                          width: w * 0.007,
                          color: AppColors.orange,
                        ),
                      ),
                      child: Text(
                        error,
                        style: AppTextStyles.code.copyWith(
                          color: AppColors.orange,
                          fontSize: w * 0.032,
                        ),
                      ),
                    ),
                  Text(
                    output.isEmpty
                        ? 'No hay salida todavía. Ejecuta el algoritmo para ver resultados.'
                        : output.join("\n"),
                    style: AppTextStyles.code.copyWith(
                      color: const Color(0xFF00FF8A),
                      fontSize: w * 0.034,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanlines(double w, double h) {
    return AnimatedBuilder(
      animation: _crtController,
      builder: (context, _) {
        return Opacity(
          opacity: 0.04 + (_crtController.value * 0.03),
          child: CustomPaint(size: Size(w, h), painter: _ScanlinePainter()),
        );
      },
    );
  }

  Widget _buildScrollHint(double w, double h) {
    return Positioned(
      bottom: h * 0.15,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, _pulseController.value * 8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: w * 0.025,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  border: Border.all(width: w * 0.008, color: Colors.black),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(w * 0.008, w * 0.008),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: w * 0.06,
                    ),
                    SizedBox(width: w * 0.02),
                    Text(
                      'VER SALIDA',
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.white,
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RetroTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.02)
      ..strokeWidth = 1;

    for (double i = 0; i < size.height; i += 3) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) => false;
}
