import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> with TickerProviderStateMixin {
  late AnimationController _c1;
  late AnimationController _c2;

  @override
  void initState() {
    super.initState();

    _c1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _c2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    Future.delayed(const Duration(milliseconds: 120), () => _c1.forward());
    Future.delayed(const Duration(milliseconds: 260), () => _c2.forward());
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final padding = w * 0.06;
    final spacing = h * 0.02;
    final cardHeight = h * 0.28; // MÁS ALTO PARA QUE NADA SE TAPE

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: SafeArea(
        child: Stack(
          children: [
            // Textura retro lineal
            Positioned.fill(
              child: CustomPaint(painter: _RetroTexturePainter()),
            ),

            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  _buildHeader(w),
                  SizedBox(height: spacing * 1.2),
                  _buildUserBar(w, h),
                  SizedBox(height: spacing * 1.5),

                  _buildCardsRow(context, w, h, cardHeight),

                  const Spacer(),

                  _buildStats(w, h),
                ],
              ),
            ),

            // CRT Scanlines
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _c1,
                  builder: (_, __) {
                    return CustomPaint(painter: _ScanlinePainter(_c1.value));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------
  Widget _buildHeader(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset("assets/images/pseudoplay_logo.png", height: w * 0.15),
        GestureDetector(
          onTap: () => context.go('/settings'),
          child: Icon(Icons.settings, size: w * 0.10, color: Colors.black),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // USER BAR — overflow FIXED
  // ------------------------------------------------------------
  Widget _buildUserBar(double w, double h) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.014),
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
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Text(
                    'USR> ',
                    style: AppTextStyles.code.copyWith(
                      fontSize: w * 0.048,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Axel Daniel Nuño',
                    style: AppTextStyles.code.copyWith(
                      fontSize: w * 0.048,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: w * 0.03),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: h * 0.009,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightPurple,
              border: Border.all(width: w * 0.006, color: Colors.black),
            ),
            child: Text(
              'EDITAR',
              style: AppTextStyles.code.copyWith(
                fontSize: w * 0.04,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ROW CARDS
  // ------------------------------------------------------------
  Widget _buildCardsRow(
    BuildContext context,
    double w,
    double h,
    double cardHeight,
  ) {
    final cardWidth = (w - (w * 0.06 * 2) - w * 0.04) / 2;

    return Row(
      children: [
        SizedBox(
          width: cardWidth,
          child: AnimatedBuilder(
            animation: _c1,
            builder: (_, __) {
              return Opacity(
                opacity: _c1.value,
                child: Transform.translate(
                  offset: Offset(-30 + 30 * _c1.value, 0),
                  child: _retroCard(
                    context,
                    w: w,
                    h: h,
                    width: cardWidth,
                    height: cardHeight,
                    title: "Ejecutar Pseudocódigo",
                    subtitle:
                        "Escribe y ejecuta código paso a paso sin complicaciones.",
                    bg: AppColors.orange,
                    route: "/editor",
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: w * 0.04),
        SizedBox(
          width: cardWidth,
          child: AnimatedBuilder(
            animation: _c2,
            builder: (_, __) {
              return Opacity(
                opacity: _c2.value,
                child: Transform.translate(
                  offset: Offset(30 - 30 * _c2.value, 0),
                  child: _retroCard(
                    context,
                    w: w,
                    h: h,
                    width: cardWidth,
                    height: cardHeight,
                    title: "Modo por bloques",
                    subtitle:
                        "Construye algoritmos arrastrando bloques con estilo retro.",
                    bg: AppColors.purple,
                    route: "/blocks",
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // RETRO CARD — FINAL, SIN OVERFLOW, SIN TAPE
  // ------------------------------------------------------------
  Widget _retroCard(
    BuildContext context, {
    required double w,
    required double h,
    required double width,
    required double height,
    required String title,
    required String subtitle,
    required Color bg,
    required String route,
  }) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(width: w * 0.008, color: Colors.black),
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
          /// TÍTULO
          Text(
            title.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.044,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: h * 0.008),

          /// DESCRIPCIÓN (no se tapa jamás)
          Expanded(
            child: Text(
              subtitle,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.code.copyWith(
                fontSize: w * 0.034,
                height: 1.25,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),

          SizedBox(height: h * 0.012),

          /// BOTÓN — SIEMPRE LIBRE
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () => context.go(route),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.07,
                  vertical: h * 0.013,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: w * 0.008, color: Colors.black),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'JUGAR',
                  style: AppTextStyles.code.copyWith(
                    fontSize: w * 0.042,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STATS
  // ------------------------------------------------------------
  Widget _buildStats(double w, double h) {
    return Column(
      children: [
        _stat("HAS JUGADO", "4 h  2 m  50 s", w, h),
        SizedBox(height: h * 0.014),
        _stat("HAS EJECUTADO", "40 algoritmos", w, h),
      ],
    );
  }

  Widget _stat(String label, String value, double w, double h) {
    return Container(
      width: w,
      padding: EdgeInsets.all(w * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFF142A18),
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
            label,
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00FF8A),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00FF8A),
            ),
          ),
        ],
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

// ============================================================
// CRT SCANLINES
// ============================================================
class _ScanlinePainter extends CustomPainter {
  final double progress;

  _ScanlinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..strokeWidth = 2;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) => true;
}
