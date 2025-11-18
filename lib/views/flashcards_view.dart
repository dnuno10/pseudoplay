import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/flashcard_carousel.dart';
import '../models/game_mode.dart';
import '../provider/user_preferences_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/context_extensions.dart';

class FlashcardsView extends ConsumerStatefulWidget {
  const FlashcardsView({super.key});

  @override
  ConsumerState<FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends ConsumerState<FlashcardsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _crtController;
  late final UserPreferencesNotifier _prefsNotifier;

  @override
  void initState() {
    super.initState();
    _crtController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _prefsNotifier = ref.read(userPreferencesProvider.notifier);
    _prefsNotifier.startSession(GameMode.flashcards);
  }

  @override
  void dispose() {
    _prefsNotifier.stopSession(GameMode.flashcards);
    _crtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final loc = context.loc;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RetroTexturePainter())),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _crtController,
              builder: (_, __) => Opacity(
                opacity: 0.04 + _crtController.value * 0.03,
                child: CustomPaint(painter: _ScanlinePainter()),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(w * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(w),
                  SizedBox(height: h * 0.02),
                  Text(
                    loc.menuFlashcardsTitle,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.purple,
                      fontSize: w * 0.085,
                    ),
                  ),
                  SizedBox(height: h * 0.015),
                  Text(
                    loc.flashcardsIntroDescription,
                    style: AppTextStyles.code.copyWith(
                      color: Colors.black87,
                      fontSize: w * 0.038,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: h * 0.03),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(w * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        border: Border.all(
                          width: w * 0.008,
                          color: Colors.black,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(6, 6),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: PseudocodeFlashcardCarousel(
                        axis: Axis.vertical,
                        cardHeight: h * 0.25,
                        padding: EdgeInsets.only(bottom: h * 0.02),
                      ),
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

  Widget _buildHeader(double w) {
    return GestureDetector(
      onTap: () => context.go('/menu'),
      child: Row(
        children: [
          Icon(Icons.arrow_back_ios, size: w * 0.08, color: AppColors.purple),
          SizedBox(width: w * 0.02),
          Text(
            context.loc.genericBack,
            style: AppTextStyles.code.copyWith(
              color: AppColors.purple,
              fontSize: w * 0.045,
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
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
