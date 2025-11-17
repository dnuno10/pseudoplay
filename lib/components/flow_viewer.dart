import 'package:flutter/material.dart';
import '../models/block_model.dart';

/// Modal retro 8-bit para visualizar todo el flujo de bloques con detalles completos
class FlowViewer extends StatefulWidget {
  final List<BlockModel> blocks;
  final Color Function(BlockModel)? colorBuilder;

  const FlowViewer({super.key, required this.blocks, this.colorBuilder});

  static void show(
    BuildContext context,
    List<BlockModel> blocks, {
    Color Function(BlockModel)? colorBuilder,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => FlowViewer(blocks: blocks, colorBuilder: colorBuilder),
    );
  }

  @override
  State<FlowViewer> createState() => _FlowViewerState();
}

class _FlowViewerState extends State<FlowViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanlineController;

  @override
  void initState() {
    super.initState();
    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: w * 0.04,
        vertical: h * 0.06,
      ),
      child: Stack(
        children: [
          // Contenedor principal RETRO
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4EEDB), // Fondo beige retro
              border: Border.all(width: 5, color: Colors.black),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(children: [_buildHeader(w), _buildBody(w, h)]),
          ),
          // CRT Scanlines
          _buildScanlines(w, h),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER RETRO ARCADE
  // ============================================================
  Widget _buildHeader(double w) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF5F2BFF),
        border: Border(bottom: BorderSide(width: 5, color: Colors.black)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'FLUJO COMPLETO',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                height: 1.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY - LISTA DE BLOQUES CON DETALLES
  // ============================================================
  Widget _buildBody(double w, double h) {
    if (widget.blocks.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2214),
                  border: Border.all(color: Colors.black, width: 4),
                ),
                child: const Icon(
                  Icons.block,
                  size: 64,
                  color: Color(0xFF00FF8A),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'NO HAY BLOQUES',
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        color: const Color(0xFFE8DCC0), // Fondo más oscuro para contraste
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: widget.blocks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) {
            final block = widget.blocks[i];
            final color = widget.colorBuilder?.call(block) ?? Colors.deepPurple;
            final indent = _calculateIndent(widget.blocks, i);

            return _buildBlockCard(block, i + 1, color, indent, w);
          },
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA DE BLOQUE CON DETALLES COMPLETOS
  // ============================================================
  Widget _buildBlockCard(
    BlockModel block,
    int number,
    Color color,
    int indent,
    double w,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: indent * 32.0),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(width: 4, color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del bloque con número
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                border: const Border(
                  bottom: BorderSide(width: 2, color: Colors.black),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getBlockTitle(block.tipo),
                      style: const TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Detalles del bloque
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildBlockDetails(block),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETALLES COMPLETOS DEL BLOQUE
  // ============================================================
  Widget _buildBlockDetails(BlockModel block) {
    switch (block.tipo) {
      case 'variable':
        return _detailRow([
          _detailLabel('Variable:'),
          _detailValue(block.data?['nombre'] ?? ''),
          _detailLabel('Valor inicial:'),
          _detailValue(block.data?['valor'] ?? ''),
        ]);

      case 'asignacion':
        return _detailRow([
          _detailLabel('Variable:'),
          _detailValue(block.data?['var'] ?? ''),
          _detailLabel('Expresión:'),
          _detailValue(block.data?['expr'] ?? ''),
        ]);

      case 'leer':
        return _detailRow([
          _detailLabel('Leer variable:'),
          _detailValue(block.data?['var'] ?? ''),
        ]);

      case 'escribir':
        return _detailRow([
          _detailLabel('Mostrar:'),
          _detailValue(block.data?['valor'] ?? ''),
        ]);

      case 'si':
        return _detailRow([
          _detailLabel('Condición:'),
          _detailValue(block.data?['condicion'] ?? ''),
        ]);

      case 'repite':
        return _detailRow([
          _detailLabel('Mientras:'),
          _detailValue(block.data?['veces'] ?? ''),
        ]);

      case 'sino':
        return const Text(
          'Alternativa (SINO)',
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 14,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        );

      case 'finsi':
        return const Text(
          'Fin de condición',
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 14,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        );

      case 'finrepite':
        return const Text(
          'Fin de bucle',
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 14,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        );

      default:
        return Text(
          block.display,
          style: const TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 14,
            color: Colors.white,
          ),
        );
    }
  }

  Widget _detailRow(List<Widget> children) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }

  Widget _detailLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 13,
        color: Colors.white70,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _detailValue(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.white54, width: 2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'IBMPlexMono',
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  String _getBlockTitle(String tipo) {
    switch (tipo) {
      case 'variable':
        return 'DECLARAR VARIABLE';
      case 'asignacion':
        return 'ASIGNAR VALOR';
      case 'leer':
        return 'LEER (ENTRADA)';
      case 'escribir':
        return 'ESCRIBIR (SALIDA)';
      case 'si':
        return 'CONDICIÓN (SI)';
      case 'sino':
        return 'SINO';
      case 'finsi':
        return 'FIN SI';
      case 'repite':
        return 'REPETIR';
      case 'finrepite':
        return 'FIN REPETIR';
      default:
        return tipo.toUpperCase();
    }
  }

  int _calculateIndent(List<BlockModel> blocks, int index) {
    int level = 0;

    for (int i = 0; i < index; i++) {
      final tipo = blocks[i].tipo;

      if (tipo == 'si' || tipo == 'repite') {
        level++;
      } else if (tipo == 'finsi' || tipo == 'finrepite') {
        level = (level - 1).clamp(0, 999);
      }
    }

    return level;
  }

  // ============================================================
  // CRT SCANLINES ANIMADAS
  // ============================================================
  Widget _buildScanlines(double w, double h) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _scanlineController,
          builder: (_, __) {
            return CustomPaint(
              painter: _ScanlinePainter(_scanlineController.value),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// PAINTER PARA SCANLINES CRT
// ============================================================
class _ScanlinePainter extends CustomPainter {
  final double progress;

  _ScanlinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..strokeWidth = 2;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) => true;
}
