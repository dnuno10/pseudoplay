import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class PredeterminedAlgorithmsView extends StatelessWidget {
  const PredeterminedAlgorithmsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Algoritmos de ejemplo", style: AppTextStyles.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _algo("Nivel 1: Suma de dos números"),
          _algo("Nivel 1: Promedio de tres valores"),
          _algo("Nivel 2: Determinar si es par o impar"),
          _algo("Nivel 2: Contador descendente"),
          _algo("Nivel 3: Buscar número en arreglo"),
          _algo("Nivel 3: Fibonacci"),
        ],
      ),
    );
  }

  Widget _algo(String title) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.codeBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(title, style: AppTextStyles.body),
      ),
    );
  }
}
