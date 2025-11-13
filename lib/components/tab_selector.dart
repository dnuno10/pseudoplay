import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class TabSelector extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onSelect;

  const TabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final bool active = selectedIndex == i;

        return Expanded(
          child: InkWell(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? AppColors.purple : AppColors.codeBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  tabs[i],
                  style: AppTextStyles.small.copyWith(
                    color: active ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
