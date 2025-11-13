import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PseudoPlay", style: AppTextStyles.title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Menú principal", style: AppTextStyles.subtitle),

            const SizedBox(height: 40),

            _HomeButton(
              color: AppColors.orange,
              text: "Ejecutar pseudocódigo",
              onTap: () => Navigator.pushNamed(context, '/editor'),
            ),

            const SizedBox(height: 20),

            _HomeButton(
              color: AppColors.purple,
              text: "Modo por bloques",
              onTap: () => Navigator.pushNamed(context, '/blocks'),
            ),

            const SizedBox(height: 20),

            _HomeButton(
              color: AppColors.softPurple,
              text: "Algoritmos de ejemplo",
              onTap: () => Navigator.pushNamed(context, '/algorithms'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _HomeButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        width: double.infinity,
        child: Text(
          text,
          style: AppTextStyles.subtitle.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
