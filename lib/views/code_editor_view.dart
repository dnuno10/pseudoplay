import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/flashcard_carousel.dart';
import '../models/game_mode.dart';
import '../provider/editor_provider.dart';
import '../provider/execution_speed_provider.dart';
import '../provider/user_preferences_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/syntax_coach.dart';
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
  late final TextInputFormatter _indentFormatter;
  ProviderSubscription<String>? _subscription;
  late final UserPreferencesNotifier _prefsNotifier;

  late AnimationController _crtController;
  bool _isKeyboardVisible = false;
  bool _isFocusMode = false;
  bool _focusFlashcardsVisible = true;

  @override
  void initState() {
    super.initState();

    _rtlSetup();
    _prefsNotifier = ref.read(userPreferencesProvider.notifier);
    _prefsNotifier.startSession(GameMode.code);
  }

  void _rtlSetup() {
    _focusNode = FocusNode();
    _scroll = ScrollController();
    _indentFormatter = PseudocodeIndentFormatter();

    // Listener para detectar cuando el teclado está visible
    _focusNode.addListener(() {
      final hasFocus = _focusNode.hasFocus;
      setState(() {
        _isKeyboardVisible = hasFocus;
        if (hasFocus) {
          _isFocusMode = true;
          _focusFlashcardsVisible = false;
        }
      });
      if (hasFocus) {
        _scrollToBottom();
      }
    });

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
    if (mounted) {
      setState(() {});
    }
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleEditorTap() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
    _scrollToBottom();
  }

  void _closeFocusMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isFocusMode = false;
      _focusFlashcardsVisible = true;
      _isKeyboardVisible = false;
    });
  }

  void _showFlashcardsInFocus() {
    FocusScope.of(context).unfocus();
    setState(() {
      _focusFlashcardsVisible = true;
    });
  }

  @override
  void dispose() {
    _prefsNotifier.stopSession(GameMode.code);
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

    return GestureDetector(
      onTap: _isFocusMode
          ? null
          : () {
              // Ocultar teclado al tocar fuera sólo cuando no estamos en modo enfoque
              FocusScope.of(context).unfocus();
            },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EEDB),
        body: Stack(
          children: [
            // Textura retro
            Positioned.fill(
              child: CustomPaint(painter: _RetroTexturePainter()),
            ),

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
                    SizedBox(height: h * 0.015),
                    _buildSpeedSelector(w, h),
                    SizedBox(height: h * 0.02),
                    _buildToolbar(w, h),
                    SizedBox(height: h * 0.02),
                    Expanded(
                      child: _isFocusMode
                          ? const SizedBox.shrink()
                          : _buildEditorArea(w, h),
                    ),
                  ],
                ),
              ),
            ),

            if (_isFocusMode) _buildEditorOverlay(w, h),
          ],
        ),
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
  // SELECTOR DE VELOCIDAD DE EJECUCIÓN
  // ------------------------------------------------------------
  Widget _buildSpeedSelector(double w, double h) {
    final speed = ref.watch(executionSpeedProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.purple,
        border: Border.all(width: w * 0.008, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Velocidad de ejecución',
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.042,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: h * 0.015),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _speedChip('Manual', 0, speed, w),
                SizedBox(width: w * 0.02),
                _speedChip('0.25s', 0.25, speed, w),
                SizedBox(width: w * 0.02),
                _speedChip('0.5s', 0.5, speed, w),
                SizedBox(width: w * 0.02),
                _speedChip('1s', 1.0, speed, w),
                SizedBox(width: w * 0.02),
                _speedChip('2s', 2.0, speed, w),
                SizedBox(width: w * 0.02),
                _speedChip('5s', 5.0, speed, w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _speedChip(
    String label,
    double speedValue,
    double currentSpeed,
    double w,
  ) {
    final selected = currentSpeed == speedValue;
    return GestureDetector(
      onTap: () => ref.read(executionSpeedProvider.notifier).state = speedValue,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.045,
          vertical: w * 0.03,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF00C851)
              : Colors.white.withOpacity(0.2),
          border: Border.all(
            width: w * 0.007,
            color: selected ? Colors.white : Colors.white.withOpacity(0.5),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.code.copyWith(
            fontSize: w * 0.037,
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PESTAÑA ALGORITMOS DE EJEMPLO (Eliminado - ahora en toolbar)
  // ------------------------------------------------------------

  void _openAlgorithms() {
    showDialog(
      context: context,
      builder: (_) => const PredeterminedAlgorithmsView(),
    );
  }

  // ------------------------------------------------------------
  // TOOLBAR: PLAY + ALGORITMOS + OCULTAR TECLADO (solo si visible)
  // ------------------------------------------------------------
  Widget _buildToolbar(double w, double h) {
    return Row(
      children: [
        // Botón PLAY
        _toolbarBtn(
          w,
          h,
          color: const Color(0xFF00C851),
          icon: Icons.play_arrow,
          onTap: () => context.go('/execution'),
        ),
        SizedBox(width: w * 0.03),
        // Botón Algoritmos de ejemplo
        Expanded(
          child: GestureDetector(
            onTap: _openAlgorithms,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2962FF),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Algoritmos",
                    style: AppTextStyles.code.copyWith(
                      color: Colors.white,
                      fontSize: w * 0.038,
                    ),
                  ),
                  Text(
                    "VER",
                    style: AppTextStyles.code.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.038,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Botón Ocultar teclado - Solo visible cuando el teclado está activo
        if (_isKeyboardVisible) ...[
          SizedBox(width: w * 0.03),
          _toolbarBtn(
            w,
            h,
            color: AppColors.purple,
            icon: Icons.keyboard_hide,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
          ),
        ],
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

  Widget _buildEditorOverlay(double w, double h) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(w * 0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!_focusFlashcardsVisible) _flashcardToggleBtn(w, h),
                    SizedBox(width: w * 0.025),
                    _toolbarBtn(
                      w,
                      h,
                      color: AppColors.purple,
                      icon: Icons.close,
                      onTap: _closeFocusMode,
                    ),
                  ],
                ),
                SizedBox(height: h * 0.02),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: _buildEditorArea(
                            w,
                            h,
                            showGuide: true,
                            allowTextExpand: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: h * 0.02),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _focusFlashcardsVisible
                      ? _buildFlashcardShelf(
                          w,
                          h,
                          key: const ValueKey('flashcards-visible'),
                        )
                      : _buildHiddenFlashcardMessage(
                          w,
                          key: const ValueKey('flashcards-hidden'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHiddenFlashcardMessage(double w, {Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.035),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border.all(width: w * 0.008, color: Colors.white24),
      ),
      child: Text(
        'Flashcards ocultas mientras editas. Toca “Mostrar flashcards” para revisarlas.',
        style: AppTextStyles.code.copyWith(
          color: Colors.white70,
          fontSize: w * 0.038,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildFlashcardShelf(double w, double h, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flashcards de palabras reservadas',
          style: AppTextStyles.code.copyWith(
            color: Colors.white,
            fontSize: w * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: h * 0.012),
        PseudocodeFlashcardCarousel(
          cardHeight: h * 0.27,
          cardWidth: w * 0.7,
          padding: EdgeInsets.only(bottom: h * 0.01),
        ),
      ],
    );
  }

  Widget _flashcardToggleBtn(double w, double h) {
    return GestureDetector(
      onTap: _showFlashcardsInFocus,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.012,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          border: Border.all(width: w * 0.008, color: Colors.white24),
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
            Icon(Icons.style, color: Colors.white, size: w * 0.06),
            SizedBox(width: w * 0.02),
            Text(
              'Mostrar flashcards',
              style: AppTextStyles.code.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: w * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ÁREA DEL EDITOR RETRO
  // ------------------------------------------------------------
  Widget _buildEditorArea(
    double w,
    double h, {
    bool showGuide = false,
    bool allowTextExpand = true,
  }) {
    return Listener(
      onPointerDown: (_) => _handleEditorTap(),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: h * 0.5),
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
          mainAxisSize: MainAxisSize.min,
          children: [
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
            if (showGuide) ...[
              _buildSyntaxGuide(w),
              SizedBox(height: h * 0.015),
            ],
            Flexible(
              fit: FlexFit.loose,
              child: Scrollbar(
                controller: _scroll,
                radius: Radius.circular(w * 0.02),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  scrollController: _scroll,
                  expands: allowTextExpand,
                  maxLines: allowTextExpand ? null : null,
                  minLines: allowTextExpand ? null : 1,
                  keyboardType: TextInputType.multiline,
                  inputFormatters: [_indentFormatter],
                  onTap: _handleEditorTap,
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

  Widget _buildSyntaxGuide(double w) {
    final hints = SyntaxCoach.buildSuggestions(_controller.text);
    if (hints.isEmpty) {
      return const SizedBox.shrink();
    }

    final hint = hints.first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        border: Border.all(width: w * 0.006, color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guía rápida para tu pseudocódigo',
            style: AppTextStyles.code.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: w * 0.035,
            ),
          ),
          SizedBox(height: w * 0.02),
          _hintChip(hint, w),
        ],
      ),
    );
  }

  Widget _hintChip(String text, double w) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.02),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border.all(width: w * 0.004, color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          color: Colors.white,
          fontSize: w * 0.032,
          height: 1.2,
        ),
      ),
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

class PseudocodeIndentFormatter extends TextInputFormatter {
  PseudocodeIndentFormatter({this.indent = '  '});

  final String indent;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= oldValue.text.length) {
      return newValue;
    }

    final selection = newValue.selection;
    final caret = selection.baseOffset;
    if (caret == 0) return newValue;

    final lastChar = newValue.text[caret - 1];
    if (lastChar != '\n') {
      return newValue;
    }

    final textBefore = newValue.text.substring(0, caret - 1);
    final lineStart = textBefore.lastIndexOf('\n') + 1;
    final previousLine = textBefore.substring(lineStart);
    final previousIndent = RegExp(r'^\s*').stringMatch(previousLine) ?? '';
    final trimmedPrev = previousLine.trim();

    var nextIndent = previousIndent;

    if (SyntaxCoach.closesBlock(trimmedPrev) &&
        nextIndent.length >= indent.length) {
      nextIndent = nextIndent.substring(0, nextIndent.length - indent.length);
    }

    if (SyntaxCoach.opensBlock(trimmedPrev)) {
      nextIndent += indent;
    }

    final insert = '\n$nextIndent';
    final updatedText = newValue.text.replaceRange(caret - 1, caret, insert);
    final offset = (caret - 1) + insert.length;

    return newValue.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}
