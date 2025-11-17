import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/editor_provider.dart';
import '../managers/execution_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CodeExecutionView extends ConsumerStatefulWidget {
  const CodeExecutionView({super.key});

  @override
  ConsumerState<CodeExecutionView> createState() => _CodeExecutionViewState();
}

class _CodeExecutionViewState extends ConsumerState<CodeExecutionView>
    with TickerProviderStateMixin {
  String? _lastSnapshot;
  bool _pending = false;

  late AnimationController _crtController;

  @override
  void initState() {
    super.initState();

    _crtController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _crtController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // DEBOUNCE PARA PROCESAR CÓDIGO
  // ------------------------------------------------------------
  void _schedule(String code) {
    final normalized = code.trim();
    if (normalized.isEmpty) return;
    if (_pending && normalized == _lastSnapshot) return;

    _pending = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pending = false;
      _lastSnapshot = normalized;
      ref.read(executionControllerProvider.notifier).procesarCodigo(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final codigo = ref.watch(editorProvider);
    final exec = ref.watch(executionControllerProvider);

    _schedule(codigo);

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: Stack(
        children: [
          // TEXTURA RETRO
          Positioned.fill(child: CustomPaint(painter: _RetroTexturePainter())),

          // CRT SCANLINES
          IgnorePointer(child: _buildScanlines(w, h)),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(w * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(w),
                  SizedBox(height: h * 0.02),
                  _buildControlButtons(w, h),
                  SizedBox(height: h * 0.02),
                  _buildEditor(codigo, w, h),
                  SizedBox(height: h * 0.02),
                  _buildVariables(exec.variables, w, h),
                  SizedBox(height: h * 0.02),
                  _buildConsole(exec.consola, exec.error, w, h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER RETRO
  // ------------------------------------------------------------
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

  // ------------------------------------------------------------
  // BOTONES PLAY / STOP RETRO
  // ------------------------------------------------------------
  Widget _buildControlButtons(double w, double h) {
    return Row(
      children: [
        _retroButton(
          w,
          h,
          color: const Color(0xFF00C851),
          icon: Icons.play_arrow,
          onTap: () {
            ref.read(executionControllerProvider.notifier).ejecutarPaso();
          },
        ),
        SizedBox(width: w * 0.03),
        _retroButton(
          w,
          h,
          color: AppColors.orange,
          icon: Icons.stop,
          onTap: () {
            ref.read(executionControllerProvider.notifier).reiniciar();
          },
        ),
      ],
    );
  }

  Widget _retroButton(
    double w,
    double h, {
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w * 0.15,
        height: w * 0.15,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(width: w * 0.008, color: Colors.black),
        ),
        child: Icon(icon, color: Colors.white, size: w * 0.09),
      ),
    );
  }

  // ------------------------------------------------------------
  // EDITOR RETRO
  // ------------------------------------------------------------
  Widget _buildEditor(String code, double w, double h) {
    return Container(
      height: h * 0.22,
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
        child: Text(
          code.isEmpty ? "// Escribe tu pseudocódigo aquí\nINICIO..." : code,
          style: AppTextStyles.code.copyWith(
            fontSize: w * 0.035,
            height: 1.3,
            color: const Color(0xFF00FFAA),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // VARIABLES EN TIEMPO REAL RETRO
  // ------------------------------------------------------------
  Widget _buildVariables(Map<String, dynamic> vars, double w, double h) {
    return Container(
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

  // ------------------------------------------------------------
  // CONSOLA RETRO DIGITAL
  // ------------------------------------------------------------
  Widget _buildConsole(List<String> output, String? error, double w, double h) {
    return Container(
      height: h * 0.22,
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
          if (error != null)
            Container(
              padding: EdgeInsets.all(w * 0.03),
              margin: EdgeInsets.only(bottom: h * 0.015),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(.12),
                border: Border.all(width: w * 0.007, color: AppColors.orange),
              ),
              child: Text(
                error,
                style: AppTextStyles.code.copyWith(
                  color: AppColors.orange,
                  fontSize: w * 0.032,
                ),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              child: Text(
                output.join("\n"),
                style: AppTextStyles.code.copyWith(
                  color: const Color(0xFF00FF8A),
                  fontSize: w * 0.034,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SCANLINES CRT
  // ------------------------------------------------------------
  Widget _buildScanlines(double w, double h) {
    return AnimatedBuilder(
      animation: _crtController,
      builder: (_, __) {
        return Opacity(
          opacity: 0.04 + (_crtController.value * 0.03),
          child: CustomPaint(size: Size(w, h), painter: _ScanlinePainter()),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// RETRO TEXTURE PAINTER
// ------------------------------------------------------------
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

// ------------------------------------------------------------
// SCANLINE PAINTER
// ------------------------------------------------------------
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
