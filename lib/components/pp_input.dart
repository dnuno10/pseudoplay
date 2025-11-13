import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class PPInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool multiline;

  const PPInput({
    super.key,
    required this.hint,
    required this.controller,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: multiline ? null : 1,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.small.copyWith(
          color: AppColors.textDark.withOpacity(0.4),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: AppColors.codeBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
