import 'package:flutter/material.dart';
import '../models/block_palette_item.dart';
import '../theme/app_text_styles.dart';

class BlockDraggable extends StatefulWidget {
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
  State<BlockDraggable> createState() => _BlockDraggableState();
}

class _BlockDraggableState extends State<BlockDraggable>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _controllerDisposed = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controllerDisposed = true;
    _progressController.dispose();
    super.dispose();
  }

  void _startProgress() {
    if (!mounted || _controllerDisposed) return;
    _progressController.forward(from: 0);
  }

  void _resetProgress() {
    if (!mounted || _controllerDisposed) return;
    _progressController.stop();
    _progressController.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final double blockWidth = widget.w * 0.70;
    final double blockHeight = widget.h * 0.10;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _startProgress(),
      onPointerUp: (_) => _resetProgress(),
      onPointerCancel: (_) => _resetProgress(),
      child: LongPressDraggable<BlockPaletteItem>(
        data: widget.item,
        delay: const Duration(milliseconds: 1000),

        onDragStarted: _resetProgress,
        onDraggableCanceled: (_, __) => _resetProgress(),
        onDragEnd: (_) => _resetProgress(),

        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: blockWidth,
            height: blockHeight,
            child: _buildBlock(isDragging: true),
          ),
        ),

        childWhenDragging: Opacity(opacity: 0.3, child: _buildBlock()),

        child: _buildBlock(),
      ),
    );
  }

  Widget _buildBlock({bool isDragging = false}) {
    return Container(
      width: isDragging ? null : double.infinity,
      decoration: BoxDecoration(
        color: widget.item.color,
        border: Border.all(width: widget.w * 0.01, color: Colors.black),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(widget.w * 0.035),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            widget.item.icono,
                            size: widget.w * 0.06,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.item.titulo,
                              style: AppTextStyles.code.copyWith(
                                fontSize: widget.w * 0.04,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.descripcion,
                        style: AppTextStyles.code.copyWith(
                          fontSize: widget.w * 0.032,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (!isDragging) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.touch_app,
                    size: widget.w * 0.055,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ],
            ),
          ),
          if (!isDragging)
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                final progress = _progressController.value.clamp(0.0, 1.0);
                return Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress == 0 ? 0.01 : progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
