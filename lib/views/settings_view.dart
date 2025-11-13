import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/theme_provider.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Ajustes", style: AppTextStyles.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Modo oscuro", style: AppTextStyles.body),
              value: dark,
              activeThumbColor: AppColors.purple,
              onChanged: (v) {
                ref.read(themeProvider.notifier).toggle(v);
              },
            ),
            const Divider(),
            ListTile(
              title: Text("Idioma", style: AppTextStyles.body),
              subtitle: Text("Español", style: AppTextStyles.small),
            ),
            const Divider(),
            ListTile(
              title: Text("Versión", style: AppTextStyles.body),
              subtitle: Text("PseudoPlay 1.0", style: AppTextStyles.small),
            ),
            ListTile(
              title: Text("Créditos", style: AppTextStyles.body),
              subtitle: Text("By Deni + GPT Compi", style: AppTextStyles.small),
            ),
          ],
        ),
      ),
    );
  }
}
