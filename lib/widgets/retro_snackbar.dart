import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum RetroSnackTone { info, success, warning, error }

class RetroSnackBar {
  const RetroSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    RetroSnackTone tone = RetroSnackTone.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    bool replaceCurrent = true,
  }) {
    final palette = _retroPalettes[tone]!;
    final messenger = ScaffoldMessenger.of(context);

    final snackBar = SnackBar(
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: palette.accent, size: 22),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.code.copyWith(
                color: palette.text,
                fontSize: 16,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.background,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: palette.border, width: 3),
      ),
    );

    if (replaceCurrent) {
      messenger.hideCurrentSnackBar();
    }
    messenger.showSnackBar(snackBar);
  }
}

class _RetroSnackPalette {
  const _RetroSnackPalette({
    required this.background,
    required this.text,
    required this.accent,
    required this.border,
  });

  final Color background;
  final Color text;
  final Color accent;
  final Color border;
}

final Map<RetroSnackTone, _RetroSnackPalette> _retroPalettes = {
  RetroSnackTone.info: _RetroSnackPalette(
    background: AppColors.purple,
    text: Colors.white,
    accent: AppColors.lightOrange,
    border: Colors.black,
  ),
  RetroSnackTone.success: _RetroSnackPalette(
    background: AppColors.green,
    text: Colors.white,
    accent: Colors.black,
    border: Colors.black,
  ),
  RetroSnackTone.warning: _RetroSnackPalette(
    background: AppColors.orange,
    text: Colors.white,
    accent: Colors.black,
    border: Colors.black,
  ),
  RetroSnackTone.error: _RetroSnackPalette(
    background: const Color(0xFFB00020),
    text: Colors.white,
    accent: AppColors.lightOrange,
    border: Colors.black,
  ),
};
