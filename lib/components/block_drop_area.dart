import 'package:flutter/material.dart';
import '../models/block_model.dart';
import '../models/block_palette_item.dart';
import '../theme/app_text_styles.dart';
import 'flow_viewer.dart';

class BlockDropArea extends StatelessWidget {
  final List<BlockModel> blocks;
  final Future<void> Function(BuildContext, BlockPaletteItem) onBlockDropped;
  final VoidCallback? onClear;
  final void Function(int index)? onRemove;
  final Color Function(BlockModel)? colorBuilder;

  final double w;
  final double h;

  const BlockDropArea({
    super.key,
    required this.blocks,
    required this.onBlockDropped,
    this.onClear,
    this.onRemove,
    this.colorBuilder,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<BlockPaletteItem>(
      onWillAccept: (_) => true,
      onAcceptWithDetails: (details) => onBlockDropped(context, details.data),
      builder: (context, candidate, _) {
        final highlight = candidate.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2214),
            border: Border.all(
              width: 4,
              color: highlight ? const Color(0xFF00FF8A) : Colors.black,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------------------------------
              // TOP HEADER BAR
              // -----------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "ZONA DE ENSAMBLE",
                      style: AppTextStyles.code.copyWith(
                        fontSize: 16,
                        color: const Color(0xFF00FF8A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (blocks.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showFlowViewer(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2962FF),
                          border: Border.all(width: 3, color: Colors.white),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "VER FLUJO",
                              style: AppTextStyles.code.copyWith(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (onClear != null && blocks.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onClear,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(width: 3, color: Colors.white),
                        ),
                        child: Text(
                          "LIMPIAR",
                          style: AppTextStyles.code.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // -----------------------------------------------------
              // GRID RETRO — NUEVA FORMA VISUAL PARA SOLTAR BLOQUES
              // -----------------------------------------------------
              Flexible(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      width: 3,
                      color: const Color(0xFF00FF8A),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: blocks.isEmpty
                        ? Center(
                            key: const ValueKey('empty-grid'),
                            child: _buildEmptyGrid(),
                          )
                        : _buildBlockList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // GRID vacío retro tipo consola (MUY más visual)
  // ------------------------------------------------------------
  Widget _buildEmptyGrid() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_box_outlined, color: Color(0xFF00FF8A), size: 25),
        Text(
          "SUELTA BLOQUES DE OPERACIÓN AQUÍ",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FF8A),
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Mantén presionado y arrastra",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 12,
            color: Color(0xFF00FF8A),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // LISTA DE BLOQUES RETRO (con scroll seguro para evitar overflow)
  // ------------------------------------------------------------
  Widget _buildBlockList() {
    return ListView.separated(
      key: const ValueKey('block-list'),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
      physics: const BouncingScrollPhysics(),
      itemCount: blocks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final block = blocks[i];
        final color = colorBuilder?.call(block) ?? Colors.deepPurple;

        return Dismissible(
          key: ValueKey("$i-${block.tipo}"),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onRemove?.call(i),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.redAccent,
            child: const Icon(Icons.delete, size: 28, color: Colors.white),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(width: 3, color: Colors.black),
            ),
            child: Text(
              block.display,
              style: AppTextStyles.code.copyWith(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFlowViewer(BuildContext context) {
    FlowViewer.show(context, blocks, colorBuilder: colorBuilder);
  }
}
