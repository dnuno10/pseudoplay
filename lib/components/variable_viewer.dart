import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class VariableViewer extends StatelessWidget {
  final Map<String, dynamic> variables;

  const VariableViewer({super.key, required this.variables});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.codeBackground,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Variables", style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          ...variables.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text("${e.key} → ${e.value}", style: AppTextStyles.body),
            ),
          ),
        ],
      ),
    );
  }
}
