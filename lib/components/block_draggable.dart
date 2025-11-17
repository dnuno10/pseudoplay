import 'package:flutter/material.dart';
import '../models/block_palette_item.dart';
import '../theme/app_text_styles.dart';

class BlockDraggable extends StatelessWidget {
  final BlockPaletteItem item;
  final double w;
  final double h;

  const BlockDraggable({
    super.key,
    required this.item,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Ancho fijo para feedback
    final double blockWidth = w * 0.70;
    final double blockHeight = h * 0.10;

    return LongPressDraggable<BlockPaletteItem>(
      data: item,

      // ----------------------------------------------------------
      // FEEDBACK: DEBE tener ancho y alto DEFINIDOS
      // ----------------------------------------------------------
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: blockWidth,
          height: blockHeight,
          child: _buildBlock(isDragging: true),
        ),
      ),

      // Versión cuando estás arrastrando
      childWhenDragging: Opacity(opacity: 0.3, child: _buildBlock()),

      child: _buildBlock(),
    );
  }

  Widget _buildBlock({bool isDragging = false}) {
    return Container(
      width: isDragging ? null : double.infinity,
      padding: EdgeInsets.all(w * 0.035),
      decoration: BoxDecoration(
        color: item.color,
        border: Border.all(width: w * 0.01, color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(item.icono, size: w * 0.06, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.titulo,
                  style: AppTextStyles.code.copyWith(
                    fontSize: w * 0.04,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.descripcion,
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.032,
              color: Colors.white.withOpacity(0.9),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
