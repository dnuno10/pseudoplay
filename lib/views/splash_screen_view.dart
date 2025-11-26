import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/user_preferences_provider.dart';
import '../theme/app_text_styles.dart';
import '../widgets/name_input_dialog.dart';

class SplashScreenView extends ConsumerStatefulWidget {
  const SplashScreenView({super.key});

  @override
  ConsumerState<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends ConsumerState<SplashScreenView>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _progressController;
  late Stopwatch _stopwatch;
  bool _done = false;

  @override
  void initState() {
    super.initState();

    _stopwatch = Stopwatch()..start();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3900),
    )..repeat(reverse: false);

    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await ref.read(userPreferencesProvider.notifier).initialize();
    if (!mounted) return;

    final prefs = ref.read(userPreferencesProvider);
    if (prefs.requiresName) {
      final newName = await NameInputDialog.show(context, force: true);
      if (newName != null && newName.trim().isNotEmpty) {
        await ref
            .read(userPreferencesProvider.notifier)
            .setUserName(newName.trim());
      }
    }

    const splashMin = Duration(milliseconds: 3900);
    final elapsed = _stopwatch.elapsed;

    if (elapsed < splashMin) {
      await Future.delayed(splashMin - elapsed);
    }

    if (!mounted || _done) return;
    _done = true;

    context.go('/menu');
  }

  @override
  void dispose() {
    _scanController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RetroTexturePainter())),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/pseudoplay_logo.png",
                  width: w * 0.58,
                ),

                SizedBox(height: h * 0.04),

                _RetroProgressBar(controller: _progressController, w: w, h: h),
              ],
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _scanController,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _CRTScanlines(progress: _scanController.value),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetroProgressBar extends StatelessWidget {
  final AnimationController controller;
  final double w;
  final double h;

  const _RetroProgressBar({
    required this.controller,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    final height = h * 0.065;
    final border = w * 0.012;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Container(
          width: w * 0.72,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            border: Border.all(color: Colors.black, width: border),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: controller.value.clamp(0.1, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(color: const Color(0xFF7B57ED)),
              ),

              Positioned.fill(child: CustomPaint(painter: _ProgressLines())),

              Center(
                child: Text(
                  "LOADING...",
                  style: AppTextStyles.code.copyWith(
                    fontSize: w * 0.045,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CRTScanlines extends CustomPainter {
  final double progress;
  _CRTScanlines({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black.withOpacity(0.05 + progress * 0.05)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _RetroTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.025)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ProgressLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
