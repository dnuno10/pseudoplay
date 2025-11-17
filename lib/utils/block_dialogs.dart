import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class BlockDialogs {
  static Future<Map<String, dynamic>?> pedirVariable(
    BuildContext context,
    List<String> declaredVars,
  ) async {
    final nombre = TextEditingController();
    final valor = TextEditingController();

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _RetroDialog(
        title: 'VARIABLE',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RetroTextField(
              controller: nombre,
              label: 'Nombre',
              hint: 'Ej: contador, suma',
            ),
            const SizedBox(height: 12),
            _RetroTextField(
              controller: valor,
              label: 'Valor inicial',
              hint: 'Ej: 0, 10, "texto"',
            ),
          ],
        ),
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          if (nombre.text.isEmpty || valor.text.isEmpty) {
            _showError(context, 'Completa todos los campos');
            return;
          }
          if (declaredVars.contains(nombre.text)) {
            _showError(context, 'La variable "${nombre.text}" ya existe');
            return;
          }
          Navigator.pop(context, {"nombre": nombre.text, "valor": valor.text});
        },
      ),
    );
  }

  static Future<Map<String, dynamic>?> pedirAsignacion(
    BuildContext context,
    List<String> declaredVars,
  ) async {
    final variable = TextEditingController();
    final expresion = TextEditingController();

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _RetroDialog(
        title: 'ASIGNACIÓN',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (declaredVars.isNotEmpty) ...[
              const Text(
                'Variables disponibles:',
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _VariableChips(
                variables: declaredVars,
                onSelect: (v) => variable.text = v,
              ),
              const SizedBox(height: 12),
            ],
            _RetroTextField(
              controller: variable,
              label: 'Variable',
              hint: 'Ej: suma, contador',
            ),
            const SizedBox(height: 12),
            const Text(
              'Variables disponibles:',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (declaredVars.isNotEmpty)
              _VariableChips(
                variables: declaredVars,
                onSelect: (v) {
                  if (expresion.text.isEmpty) {
                    expresion.text = v;
                  } else {
                    expresion.text += ' $v';
                  }
                },
              ),
            const SizedBox(height: 12),
            _RetroTextField(
              controller: expresion,
              label: 'Expresión',
              hint: 'Ej: num1 + num2, "texto"',
            ),
            const SizedBox(height: 8),
            const Text(
              'Usa variables declaradas, números o texto entre ""',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          if (variable.text.isEmpty || expresion.text.isEmpty) {
            _showError(context, 'Completa todos los campos');
            return;
          }
          if (!declaredVars.contains(variable.text)) {
            _showError(
              context,
              'Variable "${variable.text}" no ha sido declarada',
            );
            return;
          }

          // Validar expresión: solo variables declaradas, números o texto entre ""
          final exprValidation = _validateExpression(
            expresion.text,
            declaredVars,
          );
          if (!exprValidation['valid']) {
            _showError(context, exprValidation['error']);
            return;
          }

          Navigator.pop(context, {
            "var": variable.text,
            "expr": expresion.text,
          });
        },
      ),
    );
  }

  static Future<Map<String, dynamic>?> pedirLeer(
    BuildContext context,
    List<String> declaredVars,
  ) async {
    final variable = TextEditingController();

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _RetroDialog(
        title: 'LEER',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (declaredVars.isNotEmpty) ...[
              const Text(
                'Variables disponibles:',
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _VariableChips(
                variables: declaredVars,
                onSelect: (v) => variable.text = v,
              ),
              const SizedBox(height: 12),
            ],
            _RetroTextField(
              controller: variable,
              label: 'Variable',
              hint: 'Ej: num1, nombre',
            ),
          ],
        ),
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          if (variable.text.isEmpty) {
            _showError(context, 'Escribe el nombre de la variable');
            return;
          }
          if (!declaredVars.contains(variable.text)) {
            _showError(
              context,
              'Variable "${variable.text}" no ha sido declarada',
            );
            return;
          }
          Navigator.pop(context, {"var": variable.text});
        },
      ),
    );
  }

  static Future<Map<String, dynamic>?> pedirEscribir(
    BuildContext context,
    List<String> declaredVars,
  ) async {
    final valor = TextEditingController();

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _RetroDialog(
        title: 'ESCRIBIR',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (declaredVars.isNotEmpty) ...[
              const Text(
                'Variables disponibles:',
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _VariableChips(
                variables: declaredVars,
                onSelect: (v) => valor.text = v,
              ),
              const SizedBox(height: 12),
            ],
            _RetroTextField(
              controller: valor,
              label: 'Valor o variable',
              hint: 'Ej: "Hola", suma',
            ),
            const SizedBox(height: 8),
            const Text(
              'Usa variables declaradas o texto entre ""',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          if (valor.text.isEmpty) {
            _showError(context, 'Escribe el valor o variable');
            return;
          }

          // Validar expresión
          final exprValidation = _validateExpression(valor.text, declaredVars);
          if (!exprValidation['valid']) {
            _showError(context, exprValidation['error']);
            return;
          }

          Navigator.pop(context, {"valor": valor.text});
        },
      ),
    );
  }

  static Future<Map<String, dynamic>?> pedirCondicion(
    BuildContext context,
    List<String> declaredVars,
  ) async {
    final txt = TextEditingController();

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _RetroDialog(
        title: 'CONDICIÓN',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (declaredVars.isNotEmpty) ...[
              const Text(
                'Variables disponibles:',
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _VariableChips(
                variables: declaredVars,
                onSelect: (v) {
                  if (txt.text.isEmpty) {
                    txt.text = v;
                  } else {
                    txt.text += ' $v';
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
            _RetroTextField(
              controller: txt,
              label: 'Condición',
              hint: 'Ej: num > 5, edad == 18',
            ),
            const SizedBox(height: 8),
            const Text(
              'Operadores: >, <, ==, !=, >=, <=',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          if (txt.text.isEmpty) {
            _showError(context, 'Escribe una condición');
            return;
          }

          // Validar condición: solo variables declaradas y números
          final condValidation = _validateCondition(txt.text, declaredVars);
          if (!condValidation['valid']) {
            _showError(context, condValidation['error']);
            return;
          }

          Navigator.pop(context, {"condicion": txt.text});
        },
      ),
    );
  }

  static Future<Map<String, dynamic>?> pedirRepeticiones(
    BuildContext context,
    List<String> declaredVars,
  ) async {
    final txt = TextEditingController();

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _RetroDialog(
        title: 'REPETIR',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (declaredVars.isNotEmpty) ...[
              Text(
                'Variables disponibles:',
                style: AppTextStyles.code.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8),
              _VariableChips(variables: declaredVars, onSelect: null),
              const SizedBox(height: 12),
            ],
            _RetroTextField(
              controller: txt,
              label: 'Condición o veces',
              hint: 'Ej: contador < 10',
              keyboard: TextInputType.text,
            ),
          ],
        ),
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          if (txt.text.isEmpty) {
            _showError(context, 'Escribe la condición');
            return;
          }
          Navigator.pop(context, {"veces": txt.text});
        },
      ),
    );
  }

  /// Valida expresiones: solo variables declaradas, números o texto entre ""
  static Map<String, dynamic> _validateExpression(
    String expr,
    List<String> declaredVars,
  ) {
    expr = expr.trim();

    // Si está entre comillas dobles, es texto válido
    if (expr.startsWith('"') && expr.endsWith('"')) {
      return {'valid': true};
    }

    // Verificar si hay comillas mal balanceadas
    if (expr.contains('"')) {
      return {
        'valid': false,
        'error': 'Texto debe estar entre comillas dobles: "texto"',
      };
    }

    // Remover operadores y espacios para obtener tokens
    final tokens = expr
        .replaceAll(RegExp(r'[+\-*/()=<>!]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    for (final token in tokens) {
      // Si es número, válido
      if (double.tryParse(token) != null) continue;

      // Todo lo demás debe ser una variable declarada
      if (!declaredVars.contains(token)) {
        return {
          'valid': false,
          'error':
              '❌ "$token" no es una variable declarada.\n\n💡 Si es texto, usa: "$token"\n💡 Si es variable, decláral primero',
        };
      }
    }

    return {'valid': true};
  }

  /// Valida condiciones: solo variables declaradas y números
  static Map<String, dynamic> _validateCondition(
    String cond,
    List<String> declaredVars,
  ) {
    cond = cond.trim();

    // Verificar que tenga operador de comparación
    final operators = ['==', '!=', '>=', '<=', '>', '<'];
    if (!operators.any((op) => cond.contains(op))) {
      return {
        'valid': false,
        'error': 'Falta operador de comparación: >, <, ==, !=, >=, <=',
      };
    }

    // Remover operadores y espacios para obtener tokens
    final tokens = cond
        .replaceAll(RegExp(r'[+\-*/()=<>!]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    for (final token in tokens) {
      // Si es número, válido
      if (double.tryParse(token) != null) continue;

      // Si no es variable declarada, error
      if (!declaredVars.contains(token)) {
        return {
          'valid': false,
          'error':
              'Variable "$token" no declarada.\nSolo usa variables disponibles',
        };
      }
    }

    return {'valid': true};
  }

  static void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.code),
        backgroundColor: const Color(0xFFFF4D00),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ============================================================
// RETRO DIALOG WIDGET
// ============================================================
class _RetroDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _RetroDialog({
    required this.title,
    required this.content,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: w * 0.85, maxHeight: h * 0.6),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EEDB),
          border: Border.all(color: Colors.black, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(w * 0.04),
              decoration: const BoxDecoration(
                color: Color(0xFF5F2BFF),
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 3),
                ),
              ),
              child: Text(
                title,
                style: AppTextStyles.title.copyWith(
                  color: Colors.white,
                  fontSize: w * 0.05,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // CONTENT
            Flexible(
              child: Padding(padding: EdgeInsets.all(w * 0.05), child: content),
            ),

            // BUTTONS
            Container(
              padding: EdgeInsets.all(w * 0.04),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black, width: 3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _RetroButton(
                      label: 'CANCELAR',
                      color: const Color(0xFF8C8F9A),
                      onTap: onCancel,
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: _RetroButton(
                      label: 'AGREGAR',
                      color: const Color(0xFF00C853),
                      onTap: onConfirm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RETRO TEXT FIELD
// ============================================================
class _RetroTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboard;

  const _RetroTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.subtitle.copyWith(fontSize: w * 0.035),
        ),
        SizedBox(height: w * 0.02),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
          ),
          padding: EdgeInsets.symmetric(horizontal: w * 0.03),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: AppTextStyles.code.copyWith(fontSize: w * 0.04),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.code.copyWith(
                fontSize: w * 0.035,
                color: Colors.black38,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// RETRO BUTTON
// ============================================================
class _RetroButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RetroButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: w * 0.035),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Text(
          label,
          style: AppTextStyles.subtitle.copyWith(
            color: Colors.white,
            fontSize: w * 0.035,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ============================================================
// VARIABLE CHIPS - Mostrar variables declaradas
// ============================================================
class _VariableChips extends StatelessWidget {
  final List<String> variables;
  final void Function(String)? onSelect;

  const _VariableChips({required this.variables, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: variables.map((varName) {
        return GestureDetector(
          onTap: onSelect != null ? () => onSelect!(varName) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2962FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Text(
              varName,
              style: AppTextStyles.code.copyWith(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
