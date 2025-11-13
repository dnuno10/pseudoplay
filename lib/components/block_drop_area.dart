import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import 'block_widget.dart';

class BlockDropArea extends StatelessWidget {
  final List<String> blocks;
  final Function(String) onBlockDropped;

  const BlockDropArea({
    super.key,
    required this.blocks,
    required this.onBlockDropped,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAccept: onBlockDropped,
      builder: (context, candidate, rejected) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.purple, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: blocks.isEmpty
              ? Text(
                  "Arrastra bloques aquí",
                  style: AppTextStyles.small.copyWith(color: AppColors.purple),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: blocks
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BlockWidget(label: e),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}
