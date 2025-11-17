import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/editor_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'predetermined_algorithms_view.dart';

class CodeEditorView extends ConsumerStatefulWidget {
  const CodeEditorView({super.key});

  @override
  ConsumerState<CodeEditorView> createState() => _CodeEditorViewState();
}

class _CodeEditorViewState extends ConsumerState<CodeEditorView>
    with TickerProviderStateMixin {
  static const String _defaultTemplate = '''
// Escribe tu pseudocódigo aquí
INICIO
  VARIABLE num1 = 0
  VARIABLE num2 = 0
  VARIABLE suma = 0

  ESCRIBIR "Ingresa el primer número:"
  LEER num1
  ESCRIBIR "Ingresa el segundo número:"
  LEER num2

  suma = num1 + num2
  ESCRIBIR "La suma es:", suma
FIN
''';

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scroll;
  ProviderSubscription<String>? _subscription;

  late AnimationController _crtController;

  @override
  void initState() {
    super.initState();

    _rtlSetup();
  }

  void _rtlSetup() {
    _focusNode = FocusNode();
    _scroll = ScrollController();

    final text = ref.read(editorProvider);
    final resolved = text.isEmpty ? _defaultTemplate : text;

    _controller = TextEditingController(text: resolved)
      ..addListener(_handleEditorChange);

    if (text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(editorProvider.notifier).updateText(resolved);
        }
      });
    }

    _subscription = ref.listenManual(editorProvider, (prev, next) {
      if (next != _controller.text) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    _crtController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  void _handleEditorChange() {
    final text = _controller.text;
    if (text != ref.read(editorProvider)) {
      ref.read(editorProvider.notifier).updateText(text);
    }
  }

  @override
  void dispose() {
    _subscription?.close();
    _controller.removeListener(_handleEditorChange);
    _controller.dispose();
    _focusNode.dispose();
    _scroll.dispose();
    _crtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final pad = w * 0.06;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: Stack(
        children: [
          // Textura retro
          Positioned.fill(child: CustomPaint(painter: _RetroTexturePainter())),

          _buildCRTScanlines(w, h),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.012),
                  _buildBackButton(w, h),
                  SizedBox(height: h * 0.02),
                  _buildTitle(w),
                  SizedBox(height: h * 0.02),
                  _buildExampleTab(w, h),
                  SizedBox(height: h * 0.02),
                  _buildToolbar(w, h),
                  SizedBox(height: h * 0.02),
                  Expanded(child: _buildEditorArea(w, h)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CRT SCANLINES
  // ------------------------------------------------------------
  Widget _buildCRTScanlines(double w, double h) {
    return AnimatedBuilder(
      animation: _crtController,
      builder: (_, __) {
        return Opacity(
          opacity: 0.04 + _crtController.value * 0.03,
          child: CustomPaint(size: Size(w, h), painter: _ScanlinePainter()),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BOTÓN DE REGRESAR RETRO
  // ------------------------------------------------------------
  Widget _buildBackButton(double w, double h) {
    return GestureDetector(
      onTap: () => context.go('/menu'),
      child: Row(
        children: [
          Icon(Icons.arrow_back_ios, size: w * 0.07, color: AppColors.purple),
          SizedBox(width: w * 0.02),
          Text(
            "Regresar",
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.045,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TÍTULO
  // ------------------------------------------------------------
  Widget _buildTitle(double w) {
    return Text(
      "Edición de\npseudocódigo",
      style: AppTextStyles.title.copyWith(
        fontSize: w * 0.095,
        height: 1.05,
        color: AppColors.purple,
      ),
    );
  }

  // ------------------------------------------------------------
  // PESTAÑA ALGORITMOS DE EJEMPLO
  // ------------------------------------------------------------
  Widget _buildExampleTab(double w, double h) {
    return GestureDetector(
      onTap: () => _openAlgorithms(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: h * 0.018,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF00C851),
          border: Border.all(width: w * 0.008, color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Algoritmos de ejemplo",
              style: AppTextStyles.code.copyWith(
                color: Colors.white,
                fontSize: w * 0.045,
              ),
            ),
            Text(
              "VER",
              style: AppTextStyles.code.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: w * 0.045,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAlgorithms() {
    showDialog(
      context: context,
      builder: (_) => const PredeterminedAlgorithmsView(),
    );
  }

  // ------------------------------------------------------------
  // TOOLBAR PLAY / STOP
  // ------------------------------------------------------------
  Widget _buildToolbar(double w, double h) {
    return Row(
      children: [
        _toolbarBtn(
          w,
          h,
          color: const Color(0xFF00C851),
          icon: Icons.play_arrow,
          onTap: () => context.go('/execution'),
        ),
        SizedBox(width: w * 0.03),
        _toolbarBtn(w, h, color: AppColors.orange, icon: Icons.stop),
      ],
    );
  }

  Widget _toolbarBtn(
    double w,
    double h, {
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w * 0.14,
        height: w * 0.14,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(width: w * 0.008, color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, size: w * 0.085, color: Colors.white),
      ),
    );
  }

  // ------------------------------------------------------------
  // ÁREA DEL EDITOR RETRO
  // ------------------------------------------------------------
  Widget _buildEditorArea(double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        border: Border.all(width: w * 0.009, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // retro header
          Row(
            children: [
              _dot(Colors.red, w),
              SizedBox(width: w * 0.02),
              _dot(Colors.yellow, w),
              SizedBox(width: w * 0.02),
              _dot(Colors.green, w),
              SizedBox(width: w * 0.04),
              Text(
                "main.pseudo",
                style: AppTextStyles.code.copyWith(
                  color: Colors.white70,
                  fontSize: w * 0.04,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),

          // EDITOR
          Expanded(
            child: Scrollbar(
              controller: _scroll,
              radius: Radius.circular(w * 0.02),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                scrollController: _scroll,
                expands: true,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: AppTextStyles.code.copyWith(
                  fontSize: w * 0.04,
                  height: 1.25,
                  color: const Color(0xFF00FFAA),
                ),
                cursorColor: AppColors.purple,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color, double w) {
    return Container(
      width: w * 0.035,
      height: w * 0.035,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ============================================================
// TEXTURA RETRO LINEAL
// ============================================================
class _RetroTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.02)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_RetroTexturePainter oldDelegate) => false;
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
