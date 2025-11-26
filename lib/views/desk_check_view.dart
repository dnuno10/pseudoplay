import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../provider/deskcheck_provider.dart';

class DeskCheckView extends ConsumerStatefulWidget {
  const DeskCheckView({super.key});

  @override
  ConsumerState<DeskCheckView> createState() => _DeskCheckViewState();
}

class _DeskCheckViewState extends ConsumerState<DeskCheckView>
    with SingleTickerProviderStateMixin {
  int _pasoActual = 0;
  late AnimationController _crtController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _crtController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _crtController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pasos = ref.watch(deskCheckProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RetroTexturePainter())),

          IgnorePointer(
            child: AnimatedBuilder(
              animation: _crtController,
              builder: (_, __) {
                return Opacity(
                  opacity: 0.04 + (_crtController.value * 0.03),
                  child: CustomPaint(
                    size: Size(w, h),
                    painter: _ScanlinePainter(),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: h * 0.02),
                _buildHeader(w),
                SizedBox(height: h * 0.02),
                Expanded(child: _buildTable(pasos, w, h)),
                _buildFooter(pasos, w, h),
                SizedBox(height: h * 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double w) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
      child: GestureDetector(
        onTap: () => context.go('/execution'),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios, size: w * 0.07, color: AppColors.purple),
            SizedBox(width: w * 0.02),
            Text(
              'Prueba de escritorio',
              style: AppTextStyles.title.copyWith(
                fontSize: w * 0.05,
                color: AppColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> pasos, double w, double h) {
    if (pasos.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(w * 0.1),
          margin: EdgeInsets.all(w * 0.06),
          decoration: BoxDecoration(
            color: AppColors.purple,
            border: Border.all(width: w * 0.008, color: Colors.black),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            'No hay datos de\nprueba de escritorio',
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(
              color: Colors.white,
              fontSize: w * 0.05,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: w * 0.01, color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: h * 0.015,
                horizontal: w * 0.04,
              ),
              decoration: BoxDecoration(
                color: AppColors.purple,
                border: Border(
                  bottom: BorderSide(width: w * 0.008, color: Colors.black),
                ),
              ),
              child: Row(
                children: [
                  _buildHeaderCell('Paso', 15, w),
                  _buildHeaderCell('Operación', 30, w),
                  _buildHeaderCell('Variable', 27, w),
                  _buildHeaderCell('Valor', 28, w),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                itemCount: pasos.length,
                itemBuilder: (context, index) {
                  final dato = pasos[index];
                  final isHighlighted = index == _pasoActual;

                  return Container(
                    padding: EdgeInsets.symmetric(
                      vertical: h * 0.015,
                      horizontal: w * 0.04,
                    ),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? AppColors.orange.withOpacity(0.15)
                          : (index % 2 == 0
                                ? Colors.white
                                : const Color(0xFFF8F8F8)),
                      border: Border(
                        bottom: BorderSide(
                          width: w * 0.004,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildDataCell(
                          '#${(index + 1).toString().padLeft(2, '0')}',
                          15,
                          w,
                          isBold: true,
                          color: isHighlighted
                              ? AppColors.orange
                              : AppColors.purple,
                        ),
                        _buildDataCell(
                          dato['operacion'] ?? '—',
                          30,
                          w,
                          color: AppColors.textDark,
                        ),
                        _buildDataCell(
                          dato['variable'] ?? '—',
                          27,
                          w,
                          color: AppColors.textDark,
                        ),
                        _buildDataCell(
                          dato['valorNuevo'] ?? '—',
                          28,
                          w,
                          isBold: true,
                          color: AppColors.orange,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, int flex, double w) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyles.code.copyWith(
          fontSize: w * 0.032,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(
    String text,
    int flex,
    double w, {
    bool isBold = false,
    required Color color,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyles.code.copyWith(
          fontSize: w * 0.038,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _scrollToPasoIfNeeded(int paso) {
    if (!_scrollController.hasClients) return;

    final context = this.context;
    final itemHeight = MediaQuery.of(context).size.height * 0.06;
    final currentOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;

    final pasoOffset = paso * itemHeight;
    final pasoEnd = pasoOffset + itemHeight;

    final isVisible =
        pasoOffset >= currentOffset &&
        pasoEnd <= currentOffset + viewportHeight;

    if (!isVisible) {
      final targetOffset = (pasoOffset - viewportHeight / 2 + itemHeight / 2)
          .clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildFooter(List<Map<String, dynamic>> pasos, double w, double h) {
    if (pasos.isEmpty) return const SizedBox.shrink();

    final maxPasos = pasos.length;

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      margin: EdgeInsets.symmetric(horizontal: w * 0.06),
      decoration: BoxDecoration(
        color: AppColors.purple,
        border: Border.all(width: w * 0.008, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _pasoActual > 0
                ? () {
                    setState(() => _pasoActual--);
                    _scrollToPasoIfNeeded(_pasoActual);
                  }
                : null,
            child: Container(
              padding: EdgeInsets.all(w * 0.04),
              decoration: BoxDecoration(
                color: _pasoActual > 0
                    ? AppColors.orange
                    : Colors.white.withOpacity(0.2),
                border: Border.all(width: w * 0.006, color: Colors.black),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: w * 0.06,
              ),
            ),
          ),

          Text(
            '${_pasoActual + 1} / $maxPasos',
            style: AppTextStyles.title.copyWith(
              color: Colors.white,
              fontSize: w * 0.05,
            ),
          ),

          GestureDetector(
            onTap: _pasoActual < maxPasos - 1
                ? () {
                    setState(() => _pasoActual++);
                    _scrollToPasoIfNeeded(_pasoActual);
                  }
                : null,
            child: Container(
              padding: EdgeInsets.all(w * 0.04),
              decoration: BoxDecoration(
                color: _pasoActual < maxPasos - 1
                    ? AppColors.orange
                    : Colors.white.withOpacity(0.2),
                border: Border.all(width: w * 0.006, color: Colors.black),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: w * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetroTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.02)
      ..strokeWidth = 1;

    for (double i = 0; i < size.height; i += 4) {
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
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1.5;

    for (double i = 0; i < size.height; i += 3) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
