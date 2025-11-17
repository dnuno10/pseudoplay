import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isDarkMode = false; // UI only (logic se integra en providers después)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              _buildHeader(context),

              const SizedBox(height: 14),
              Text(
                "Ajustes",
                style: AppTextStyles.title.copyWith(fontSize: 32),
              ),

              const SizedBox(height: 22),
              _buildSettingsBox(),

              const Spacer(),
              _buildSaveButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER < Regresar >
  // ------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/menu'),
      child: Row(
        children: [
          Icon(Icons.arrow_back, size: 28, color: AppColors.black),
          const SizedBox(width: 6),
          Text("Regresar", style: AppTextStyles.subtitle),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CAJA DE AJUSTES (tema oscuro)
  // ------------------------------------------------------------
  Widget _buildSettingsBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple, width: 2),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Apariencia",
            style: AppTextStyles.subtitle.copyWith(fontSize: 22),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Modo oscuro",
                style: AppTextStyles.body.copyWith(fontSize: 18),
              ),
              Switch(
                value: isDarkMode,
                activeColor: AppColors.purple,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTÓN GUARDAR
  // ------------------------------------------------------------
  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Aquí se integrará themeProvider
        context.go('/menu');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            "Guardar cambios",
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
