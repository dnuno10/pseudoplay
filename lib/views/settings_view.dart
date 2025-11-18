import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../provider/user_preferences_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/context_extensions.dart';
import '../widgets/name_input_dialog.dart';
import '../widgets/retro_snackbar.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final loc = context.loc;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _RetroTexturePainter()),
            ),
            Positioned.fill(child: CustomPaint(painter: _ScanlinePainter())),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  Text(
                    loc.settingsTitle,
                    style: AppTextStyles.title.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 20),
                  _profileCard(
                    context,
                    ref,
                    prefs.userName ?? loc.nameDialogPlaceholder,
                    loc,
                  ),
                  const SizedBox(height: 16),
                  _languageCard(context, ref, prefs.locale.languageCode, loc),
                  const SizedBox(height: 16),
                  _dangerZone(context, ref, loc),
                  const SizedBox(height: 16),
                  _policyCard(context, loc),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/menu'),
      child: Row(
        children: [
          Icon(Icons.arrow_back, size: 28, color: AppColors.black),
          const SizedBox(width: 6),
          Text(context.loc.genericBack, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }

  Widget _profileCard(
    BuildContext context,
    WidgetRef ref,
    String userName,
    AppLocalizations loc,
  ) {
    return _RetroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${loc.menuUserPrefix} $userName',
            style: AppTextStyles.code.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          _RetroSquareButton(
            label: loc.settingsRenameButton,
            backgroundColor: AppColors.purple,
            onTap: () async {
              final result = await NameInputDialog.show(context);
              if (result == null || result.trim().isEmpty) return;
              await ref
                  .read(userPreferencesProvider.notifier)
                  .setUserName(result.trim());
            },
          ),
        ],
      ),
    );
  }

  Widget _languageCard(
    BuildContext context,
    WidgetRef ref,
    String code,
    AppLocalizations loc,
  ) {
    return _RetroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.settingsLanguageLabel, style: AppTextStyles.subtitle),
          const SizedBox(height: 4),
          Text(
            loc.settingsLanguageDescription,
            style: AppTextStyles.body.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RetroChoiceButton(
                label: loc.settingsLanguageSpanish,
                selected: code == 'es',
                onTap: () {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .setLocale(const Locale('es'));
                  RetroSnackBar.show(
                    context,
                    message: loc.snackbarLanguageUpdated,
                    tone: RetroSnackTone.success,
                    icon: Icons.translate_rounded,
                  );
                },
              ),
              const SizedBox(width: 12),
              _RetroChoiceButton(
                label: loc.settingsLanguageEnglish,
                selected: code == 'en',
                onTap: () {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .setLocale(const Locale('en'));
                  RetroSnackBar.show(
                    context,
                    message: loc.snackbarLanguageUpdated,
                    tone: RetroSnackTone.success,
                    icon: Icons.translate_rounded,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dangerZone(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
  ) {
    return _RetroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.settingsClearCacheButton, style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Text(
            loc.settingsClearCacheConfirm,
            style: AppTextStyles.body.copyWith(color: Colors.redAccent),
          ),
          const SizedBox(height: 12),
          _RetroSquareButton(
            label: loc.settingsClearCacheButton,
            backgroundColor: Colors.redAccent,
            onTap: () async {
              await ref.read(userPreferencesProvider.notifier).clearAll();
              if (!context.mounted) return;
              RetroSnackBar.show(
                context,
                message: loc.snackbarCacheCleared,
                tone: RetroSnackTone.warning,
                icon: Icons.storage_rounded,
              );
              context.go('/splash');
            },
          ),
        ],
      ),
    );
  }

  Widget _policyCard(BuildContext context, AppLocalizations loc) {
    return _RetroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegalLinkTile(
            title: loc.settingsTermsTitle,
            body: loc.settingsTermsBody,
            actionLabel: loc.settingsOpenTerms,
            onTap: () => context.go('/terms'),
          ),
          const SizedBox(height: 18),
          _LegalLinkTile(
            title: loc.settingsPrivacyTitle,
            body: loc.settingsPrivacyBody,
            actionLabel: loc.settingsOpenPrivacy,
            onTap: () => context.go('/privacy'),
          ),
        ],
      ),
    );
  }
}

class _RetroCard extends StatelessWidget {
  const _RetroCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.4),
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RetroChoiceButton extends StatelessWidget {
  const _RetroChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple : Colors.transparent,
            border: Border.all(color: AppColors.purple, width: 2),
          ),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.code.copyWith(
                color: selected ? Colors.white : AppColors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RetroSquareButton extends StatelessWidget {
  const _RetroSquareButton({
    required this.label,
    required this.backgroundColor,
    required this.onTap,
    this.textColor = Colors.white,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.35),
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.code.copyWith(
              color: textColor,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalLinkTile extends StatelessWidget {
  const _LegalLinkTile({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.subtitle),
        const SizedBox(height: 6),
        Text(
          body,
          style: AppTextStyles.body.copyWith(
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        _RetroSquareButton(
          label: actionLabel,
          backgroundColor: Colors.white,
          textColor: AppColors.black,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _RetroTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.02)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.08)
      ..strokeWidth = 2;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
