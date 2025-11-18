import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/user_preferences_state.dart';
import '../provider/user_preferences_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/context_extensions.dart';
import '../utils/time_formatter.dart';
import '../widgets/name_input_dialog.dart';

class MenuView extends ConsumerStatefulWidget {
  const MenuView({super.key});

  @override
  ConsumerState<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends ConsumerState<MenuView>
    with TickerProviderStateMixin {
  late AnimationController _c1;
  late AnimationController _c2;
  Timer? _card1Timer;
  Timer? _card2Timer;

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

    _card1Timer = Timer(const Duration(milliseconds: 120), () {
      if (mounted) _c1.forward(from: 0);
    });
    _card2Timer = Timer(const Duration(milliseconds: 260), () {
      if (mounted) _c2.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _card1Timer?.cancel();
    _card2Timer?.cancel();
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);
    final loc = context.loc;
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(w),
                    SizedBox(height: spacing * 1.2),
                    _buildUserBar(
                      w,
                      h,
                      ref,
                      prefs.userName ?? loc.nameDialogPlaceholder,
                      loc,
                    ),
                    SizedBox(height: spacing * 1.5),

                    _buildCardsRow(context, w, h, cardHeight, loc),
                    SizedBox(height: spacing * 1.2),
                    _buildFlashcardCard(context, w, h, loc),
                    SizedBox(height: spacing * 1.5),

                    _buildStats(w, h, prefs, loc),
                  ],
                ),
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

  Widget _buildFlashcardCard(
    BuildContext context,
    double w,
    double h,
    AppLocalizations loc,
  ) {
    final height = h * 0.26;
    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1E2C),
        border: Border.all(width: w * 0.008, color: Colors.black),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.menuFlashcardsTitle,
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: h * 0.012),
          Expanded(
            child: Text(
              loc.menuFlashcardsDescription,
              style: AppTextStyles.code.copyWith(
                fontSize: w * 0.037,
                color: Colors.white70,
                height: 1.3,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => context.go('/flashcards'),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.08,
                  vertical: h * 0.013,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  border: Border.all(width: w * 0.008, color: Colors.black),
                  boxShadow: [
                    const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  loc.menuFlashcardsCTA.toUpperCase(),
                  style: AppTextStyles.code.copyWith(
                    fontSize: w * 0.045,
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
  Widget _buildUserBar(
    double w,
    double h,
    WidgetRef ref,
    String userName,
    AppLocalizations loc,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.014),
      decoration: BoxDecoration(
        color: AppColors.purple,
        border: Border.all(width: w * 0.008, color: Colors.black),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            offset: Offset(6, 6),
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
                    '${loc.menuUserPrefix} ',
                    style: AppTextStyles.code.copyWith(
                      fontSize: w * 0.048,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    userName,
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

          GestureDetector(
            onTap: () async {
              final result = await NameInputDialog.show(context);
              if (result == null || result.trim().isEmpty) return;
              await ref
                  .read(userPreferencesProvider.notifier)
                  .setUserName(result.trim());
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.009,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightPurple,
                border: Border.all(width: w * 0.006, color: Colors.black),
              ),
              child: Text(
                loc.menuEditButton.toUpperCase(),
                style: AppTextStyles.code.copyWith(
                  fontSize: w * 0.04,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
    AppLocalizations loc,
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
                    title: loc.menuExecuteTitle,
                    subtitle: loc.menuExecuteSubtitle,
                    bg: AppColors.orange,
                    route: '/editor',
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
                    title: loc.menuBlocksTitle,
                    subtitle: loc.menuBlocksSubtitle,
                    bg: AppColors.purple,
                    route: '/blocks',
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
    final loc = context.loc;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(width: w * 0.008, color: Colors.black),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            offset: Offset(6, 6),
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
                color: Color.fromRGBO(255, 255, 255, 0.9),
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
                    const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  loc.menuPlayButton.toUpperCase(),
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
  Widget _buildStats(
    double w,
    double h,
    UserPreferencesState prefs,
    AppLocalizations loc,
  ) {
    final totalTimeText = TimeFormatter.formatDuration(
      prefs.totalPlaytime,
      loc,
    );
    final algoText = loc.statsAlgorithmsValue(prefs.algorithmsExecuted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stat(loc.menuPlaytimeLabel.toUpperCase(), totalTimeText, w, h),
        SizedBox(height: h * 0.014),
        _stat(loc.menuAlgorithmsLabel.toUpperCase(), algoText, w, h),
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
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.code.copyWith(
                fontSize: w * 0.042,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00FF8A),
              ),
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.code.copyWith(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FF8A),
                ),
              ),
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
      ..color = const Color.fromRGBO(0, 0, 0, 0.02)
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
      ..color = const Color.fromRGBO(0, 0, 0, 0.03)
      ..strokeWidth = 2;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) => true;
}
