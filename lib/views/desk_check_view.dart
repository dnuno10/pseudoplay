import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../provider/deskcheck_provider.dart';

class DeskCheckView extends ConsumerStatefulWidget {
  const DeskCheckView({super.key});

  @override
  ConsumerState<DeskCheckView> createState() => _DeskCheckViewState();
}

class _DeskCheckViewState extends ConsumerState<DeskCheckView> {
  int _pasoActual = 0;

  @override
  Widget build(BuildContext context) {
    final pasos = ref.watch(deskCheckProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(child: _buildTable(pasos)),
            _buildFooter(pasos),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// ------------------------------------------------------------
  /// HEADER < Prueba de escritorio
  /// ------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go('/execution'),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: AppColors.purple,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prueba de\nescritorio',
                  style: AppTextStyles.title.copyWith(
                    fontSize: 24,
                    height: 1.1,
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/execution'),
            child: const Icon(Icons.close, size: 28, color: AppColors.black),
          ),
        ],
      ),
    );
  }

  /// ------------------------------------------------------------
  /// TABLA DE PASOS
  /// ------------------------------------------------------------
  Widget _buildTable(List<Map<String, dynamic>> pasos) {
    // Datos de ejemplo si no hay pasos reales
    final datos = pasos.isEmpty
        ? [
            {
              'linea': '1',
              'operacion': 'INICIO',
              'variable': '-',
              'valorNuevo': '-',
            },
            {
              'linea': '2',
              'operacion': 'DECLARAR',
              'variable': 'num1',
              'valorNuevo': '0',
            },
            {
              'linea': '3',
              'operacion': 'DECLARAR',
              'variable': 'num2',
              'valorNuevo': '0',
            },
            {
              'linea': '4',
              'operacion': 'DECLARAR',
              'variable': 'suma',
              'valorNuevo': '0',
            },
            {
              'linea': '6',
              'operacion': 'ESCRIBIR',
              'variable': '-',
              'valorNuevo': '-',
            },
            {
              'linea': '7',
              'operacion': 'LEER',
              'variable': 'num1',
              'valorNuevo': '10',
            },
            {
              'linea': '8',
              'operacion': 'ESCRIBIR',
              'variable': '-',
              'valorNuevo': '-',
            },
            {
              'linea': '9',
              'operacion': 'LEER',
              'variable': 'num2',
              'valorNuevo': '20',
            },
            {
              'linea': '11',
              'operacion': 'ASIGNAR',
              'variable': 'suma',
              'valorNuevo': '30',
            },
            {
              'linea': '12',
              'operacion': 'ESCRIBIR',
              'variable': '-',
              'valorNuevo': '-',
            },
          ]
        : pasos;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.codeBackground,
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Row(
              children: [
                _headerCell('Línea', flex: 1),
                _headerCell('Operación', flex: 2),
                _headerCell('Variable', flex: 2),
                _headerCell('Valor nuevo', flex: 2),
              ],
            ),
          ),
          // Data rows
          ...datos.asMap().entries.map((entry) {
            final index = entry.key;
            final dato = entry.value;
            final isHighlighted = index == _pasoActual;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? AppColors.lightPurple.withValues(alpha: 0.3)
                    : Colors.white,
                border: Border(
                  left: BorderSide(color: AppColors.lightGrey),
                  right: BorderSide(color: AppColors.lightGrey),
                  bottom: BorderSide(color: AppColors.lightGrey),
                ),
              ),
              child: Row(
                children: [
                  _dataCell(dato['linea'] ?? '', flex: 1, index: index + 1),
                  _dataCell(dato['operacion'] ?? '', flex: 2),
                  _dataCell(dato['variable'] ?? '', flex: 2),
                  _dataCell(dato['valorNuevo'] ?? '', flex: 2),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyles.code.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _dataCell(String text, {int flex = 1, int? index}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (index != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.purple,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: AppTextStyles.code.copyWith(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.code.copyWith(
                fontSize: 14,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------------------------------------------------
  /// FOOTER - Navegación y paso actual
  /// ------------------------------------------------------------
  Widget _buildFooter(List<Map<String, dynamic>> pasos) {
    final maxPasos = pasos.isEmpty ? 10 : pasos.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso actual:',
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _pasoActual == 0
                ? 'Inicio del programa'
                : 'Línea ${_pasoActual + 1}',
            style: AppTextStyles.title.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botón ANTERIOR
              GestureDetector(
                onTap: _pasoActual > 0
                    ? () => setState(() => _pasoActual--)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _pasoActual > 0
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ANTERIOR',
                    style: AppTextStyles.code.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón SIGUIENTE
              GestureDetector(
                onTap: _pasoActual < maxPasos - 1
                    ? () => setState(() => _pasoActual++)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _pasoActual < maxPasos - 1
                        ? AppColors.lightPurple
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'SIGUIENTE',
                    style: AppTextStyles.code.copyWith(
                      color: AppColors.purple,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
