import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/user_preferences_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/context_extensions.dart';

class NameInputDialog {
  const NameInputDialog._();

  static Future<String?> show(BuildContext context, {bool force = false}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: !force,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _NameDialogBody(force: force),
    );
  }
}

class _NameDialogBody extends ConsumerStatefulWidget {
  const _NameDialogBody({required this.force});

  final bool force;

  @override
  ConsumerState<_NameDialogBody> createState() => _NameDialogBodyState();
}

class _NameDialogBodyState extends ConsumerState<_NameDialogBody> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final existing = ref.read(userPreferencesProvider).userName;
    if (existing != null) {
      _controller.text = existing;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: _RetroDialogFrame(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.nameDialogTitle.toUpperCase(),
                style: AppTextStyles.code.copyWith(
                  color: AppColors.purple,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.nameDialogMessage,
                style: AppTextStyles.body.copyWith(
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextFormField(
                  controller: _controller,
                  autofocus: true,
                  style: AppTextStyles.code.copyWith(
                    color: AppColors.black,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: loc.nameDialogPlaceholder,
                    hintStyle: AppTextStyles.code.copyWith(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.nameRequiredError;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!widget.force)
                    _RetroDialogButton(
                      label: loc.nameDialogCancel,
                      onTap: () => Navigator.of(context).maybePop(),
                      secondary: true,
                    ),
                  const SizedBox(width: 12),
                  _RetroDialogButton(
                    label: loc.nameDialogConfirm,
                    onTap: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final trimmed = _controller.text.trim();
                      if (context.mounted) {
                        Navigator.of(context).pop(trimmed);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetroDialogFrame extends StatelessWidget {
  const _RetroDialogFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1D5),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.35),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RetroDialogButton extends StatelessWidget {
  const _RetroDialogButton({
    required this.label,
    required this.onTap,
    this.secondary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final bg = secondary ? Colors.white : AppColors.purple;
    final textColor = secondary ? AppColors.purple : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.code.copyWith(
            color: textColor,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
