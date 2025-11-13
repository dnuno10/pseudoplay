import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class PPCard extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onTap;

  const PPCard({super.key, required this.title, this.description, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.codeBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.subtitle),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(description!, style: AppTextStyles.small),
            ],
          ],
        ),
      ),
    );
  }
}
