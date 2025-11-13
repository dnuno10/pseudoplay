import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class PPButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const PPButton({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(color: Colors.white),
      ),
    );
  }
}
