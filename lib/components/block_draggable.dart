import 'package:flutter/material.dart';
import 'block_widget.dart';

class BlockDraggable extends StatelessWidget {
  final String label;

  const BlockDraggable({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: BlockWidget(label: label),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: BlockWidget(label: label),
      ),
      child: BlockWidget(label: label),
    );
  }
}
