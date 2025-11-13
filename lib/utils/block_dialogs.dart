import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class BlockDialogs {
  static Future<Map<String, dynamic>?> pedirVariable(
    BuildContext context,
  ) async {
    final nombre = TextEditingController();
    final valor = TextEditingController();

    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Variable", style: AppTextStyles.subtitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombre,
              decoration: const InputDecoration(hintText: "Nombre"),
            ),
            TextField(
              controller: valor,
              decoration: const InputDecoration(hintText: "Valor"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
            child: const Text("Agregar"),
            onPressed: () => Navigator.pop(context, {
              "nombre": nombre.text,
              "valor": valor.text,
            }),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>?> pedirAsignacion(
    BuildContext context,
  ) async {
    final variable = TextEditingController();
    final expresion = TextEditingController();

    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Asignación", style: AppTextStyles.subtitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: variable,
              decoration: const InputDecoration(hintText: "Variable"),
            ),
            TextField(
              controller: expresion,
              decoration: const InputDecoration(hintText: "Expresión"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Agregar"),
            onPressed: () => Navigator.pop(context, {
              "var": variable.text,
              "expr": expresion.text,
            }),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>?> pedirLeer(BuildContext context) async {
    final variable = TextEditingController();

    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Leer variable", style: AppTextStyles.subtitle),
        content: TextField(
          controller: variable,
          decoration: const InputDecoration(hintText: "Variable"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Agregar"),
            onPressed: () => Navigator.pop(context, {"var": variable.text}),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>?> pedirEscribir(
    BuildContext context,
  ) async {
    final valor = TextEditingController();

    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Escribir", style: AppTextStyles.subtitle),
        content: TextField(
          controller: valor,
          decoration: const InputDecoration(hintText: "Valor o variable"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Agregar"),
            onPressed: () => Navigator.pop(context, {"valor": valor.text}),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>?> pedirCondicion(
    BuildContext context,
  ) async {
    final txt = TextEditingController();

    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Condición", style: AppTextStyles.subtitle),
        content: TextField(
          controller: txt,
          decoration: const InputDecoration(
            hintText: "Ejemplo: x > 5 ó contador == 10",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Agregar"),
            onPressed: () => Navigator.pop(context, {"condicion": txt.text}),
          ),
        ],
      ),
    );
  }
}
