import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class BlockWidget extends StatelessWidget {
  final String label;
  final Color color;

  const BlockWidget({
    super.key,
    required this.label,
    this.color = AppColors.softPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(color: Colors.white),
      ),
    );
  }
}
