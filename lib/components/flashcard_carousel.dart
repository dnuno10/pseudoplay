import 'package:flutter/material.dart';

import '../data/pseudocode_flashcards.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PseudocodeFlashcardCarousel extends StatelessWidget {
  const PseudocodeFlashcardCarousel({
    super.key,
    this.axis = Axis.horizontal,
    this.cardWidth,
    this.cardHeight,
    this.padding,
  });

  final Axis axis;
  final double? cardWidth;
  final double? cardHeight;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final listView = ListView.separated(
      padding: padding ?? EdgeInsets.zero,
      scrollDirection: axis,
      itemBuilder: (_, index) {
        final data = pseudocodeFlashcards[index];
        return _FlashcardTile(data: data, width: cardWidth, height: cardHeight);
      },
      separatorBuilder: (_, __) => axis == Axis.horizontal
          ? const SizedBox(width: 16)
          : const SizedBox(height: 16),
      itemCount: pseudocodeFlashcards.length,
    );

    if (axis == Axis.horizontal) {
      return SizedBox(height: cardHeight, child: listView);
    }
    return listView;
  }
}

class _FlashcardTile extends StatefulWidget {
  const _FlashcardTile({required this.data, this.width, this.height});

  final PseudocodeFlashcard data;
  final double? width;
  final double? height;

  @override
  State<_FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<_FlashcardTile> {
  bool _isFlipped = false;

  void _toggleCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: _toggleCard,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isFlipped
              ? const Color(0xFF1C1C1C)
              : AppColors.cardBackground,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(offset: Offset(4, 4), color: Colors.black, blurRadius: 0),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isFlipped ? _buildBack(context) : _buildFront(context),
        ),
      ),
    );

    return card;
  }

  Widget _buildFront(BuildContext context) {
    return Column(
      key: const ValueKey('front'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.data.title,
          style: AppTextStyles.subtitle.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Text(
            widget.data.description,
            style: AppTextStyles.small.copyWith(
              color: Colors.black87,
              height: 1.25,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            'Toca para ver ejemplo',
            style: AppTextStyles.small.copyWith(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBack(BuildContext context) {
    return Column(
      key: const ValueKey('back'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.data.title,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.lightPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border.all(color: Colors.white24),
            ),
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Text(
                widget.data.codeExample,
                style: AppTextStyles.code.copyWith(
                  color: const Color(0xFF00FFAA),
                  fontSize: 14,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            'Toca para volver',
            style: AppTextStyles.small.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
