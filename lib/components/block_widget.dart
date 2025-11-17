import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class BlockWidget extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;

  const BlockWidget({
    super.key,
    required this.label,
    this.subtitle,
    this.onTap,
    this.color = AppColors.softPurple,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTextStyles.small.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: content,
        ),
      ),
    );
  }
}
