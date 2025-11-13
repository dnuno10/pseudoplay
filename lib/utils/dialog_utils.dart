import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class DialogUtils {
  static void mostrarError(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error", style: AppTextStyles.subtitle),
        content: Text(mensaje, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cerrar", style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}
