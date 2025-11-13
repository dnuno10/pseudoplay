import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PPConsole extends StatelessWidget {
  final List<String> output;

  const PPConsole({super.key, required this.output});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.consoleBackground,
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: output.length,
        itemBuilder: (_, i) {
          return Text(output[i], style: AppTextStyles.console);
        },
      ),
    );
  }
}
