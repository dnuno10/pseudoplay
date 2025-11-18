import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LegalSectionData {
  const LegalSectionData({required this.title, required this.body});

  final String title;
  final String body;
}

class LegalViewShell extends StatelessWidget {
  const LegalViewShell({
    super.key,
    required this.title,
    required this.sections,
    required this.onBack,
    required this.backLabel,
  });

  final String title;
  final List<LegalSectionData> sections;
  final VoidCallback onBack;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _RetroTexturePainter()),
            ),
            Positioned.fill(child: CustomPaint(painter: _ScanlinePainter())),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, color: AppColors.black),
                        const SizedBox(width: 8),
                        Text(
                          backLabel.toUpperCase(),
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(fontSize: 34),
                  ),
                  const SizedBox(height: 24),
                  for (final section in sections) ...[
                    _LegalCard(section: section),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  const _LegalCard({required this.section});

  final LegalSectionData section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.35),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title.toUpperCase(),
            style: AppTextStyles.subtitle.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 10),
          Text(section.body, style: AppTextStyles.body.copyWith(height: 1.4)),
        ],
      ),
    );
  }
}

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.08)
      ..strokeWidth = 2;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
