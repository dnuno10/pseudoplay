import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/editor_provider.dart';
import '../provider/predetermined_algorithms_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/predetermined_algorithm.dart';

class PredeterminedAlgorithmsView extends ConsumerStatefulWidget {
  const PredeterminedAlgorithmsView({super.key});

  @override
  ConsumerState<PredeterminedAlgorithmsView> createState() =>
      _PredeterminedAlgorithmsViewState();
}

class _PredeterminedAlgorithmsViewState
    extends ConsumerState<PredeterminedAlgorithmsView>
    with TickerProviderStateMixin {
  late AnimationController _crtController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _crtController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _crtController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final algorithms = ref.watch(predeterminedAlgorithmsProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: w * 0.06,
        vertical: h * 0.08,
      ),
      child: Stack(
        children: [
          // CRT scanlines
          _buildScanlines(w, h),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF4EEDB),
              border: Border.all(width: w * 0.012, color: Colors.black),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(w, h),
                Divider(height: 0, thickness: w * 0.01, color: Colors.black),
                _buildTabs(w, h),
                Divider(height: 0, thickness: w * 0.008, color: Colors.black),
                Expanded(child: _buildTabContent(w, h, algorithms)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CRT SCANLINES
  // ------------------------------------------------------------
  Widget _buildScanlines(double w, double h) {
    return AnimatedBuilder(
      animation: _crtController,
      builder: (_, __) {
        return Opacity(
          opacity: 0.04 + (_crtController.value * 0.03),
          child: CustomPaint(size: Size(w, h), painter: _ScanlinePainter()),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // HEADER RETRO
  // ------------------------------------------------------------
  Widget _buildHeader(double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
      decoration: BoxDecoration(
        color: AppColors.purple,
        border: Border(
          bottom: BorderSide(width: w * 0.01, color: Colors.black),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "ALGORITMOS PREDETERMINADOS",
              style: AppTextStyles.code.copyWith(
                fontSize: w * 0.05,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(w * 0.02),
              decoration: BoxDecoration(
                border: Border.all(width: w * 0.01, color: Colors.black),
                color: Colors.white,
              ),
              child: Icon(Icons.close, size: w * 0.065, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TABS DE NIVEL
  // ------------------------------------------------------------
  Widget _buildTabs(double w, double h) {
    return Container(
      color: AppColors.purple.withOpacity(0.1),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black.withOpacity(0.5),
        indicatorColor: AppColors.orange,
        indicatorWeight: w * 0.01,
        labelStyle: AppTextStyles.code.copyWith(
          fontSize: w * 0.042,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        tabs: [
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: h * 0.01),
              child: const Text('NIVEL 1'),
            ),
          ),
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: h * 0.01),
              child: const Text('NIVEL 2'),
            ),
          ),
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: h * 0.01),
              child: const Text('NIVEL 3'),
            ),
          ),
        ],
        indicator: BoxDecoration(
          color: AppColors.purple,
          border: Border.all(width: w * 0.008, color: Colors.black),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CONTENIDO DE TABS
  // ------------------------------------------------------------
  Widget _buildTabContent(
    double w,
    double h,
    List<PredeterminedAlgorithm> algorithms,
  ) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(w, h, algorithms.where((a) => a.nivel == 1).toList()),
        _buildList(w, h, algorithms.where((a) => a.nivel == 2).toList()),
        _buildList(w, h, algorithms.where((a) => a.nivel == 3).toList()),
      ],
    );
  }

  // ------------------------------------------------------------
  // LISTA RETRO
  // ------------------------------------------------------------
  Widget _buildList(double w, double h, List<PredeterminedAlgorithm> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          "No hay algoritmos disponibles",
          style: AppTextStyles.code.copyWith(fontSize: w * 0.04),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(w * 0.04),
      itemCount: data.length,
      itemBuilder: (_, i) {
        return Padding(
          padding: EdgeInsets.only(bottom: h * 0.02),
          child: _AlgorithmCard(
            w: w,
            h: h,
            algorithm: data[i],
            onPreview: () => _showPreview(w, h, data[i]),
            onLoad: () {
              ref.read(editorProvider.notifier).updateText(data[i].codigo);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // PREVIEW RETRO
  // ------------------------------------------------------------
  void _showPreview(double w, double h, PredeterminedAlgorithm algorithm) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: w * 0.08),
          child: Stack(
            children: [
              _buildScanlines(w, h),
              Container(
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: const Color(0xFF142A18),
                  border: Border.all(width: w * 0.012, color: Colors.black),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(8, 8),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            algorithm.titulo,
                            style: AppTextStyles.code.copyWith(
                              fontSize: w * 0.05,
                              color: const Color(0xFF00FF8A),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: EdgeInsets.all(w * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(
                                width: w * 0.008,
                                color: Colors.white,
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              color: const Color(0xFF00FF8A),
                              size: w * 0.06,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.02),
                    Container(
                      height: h * 0.45,
                      width: double.infinity,
                      padding: EdgeInsets.all(w * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          width: w * 0.008,
                          color: const Color(0xFF00FF8A),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          algorithm.codigo,
                          style: AppTextStyles.code.copyWith(
                            fontSize: w * 0.04,
                            color: const Color(0xFF00FF8A),
                            height: 1.28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// CARD DE ALGORITMO — ESTILO RETRO ARCADE
// ---------------------------------------------------------------------
class _AlgorithmCard extends StatelessWidget {
  final double w;
  final double h;
  final PredeterminedAlgorithm algorithm;
  final VoidCallback onPreview;
  final VoidCallback onLoad;

  const _AlgorithmCard({
    required this.w,
    required this.h,
    required this.algorithm,
    required this.onPreview,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.purple,
        border: Border.all(width: w * 0.012, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  algorithm.titulo.toUpperCase(),
                  style: AppTextStyles.code.copyWith(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.03,
                  vertical: h * 0.005,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C851),
                  border: Border.all(width: w * 0.006, color: Colors.black),
                ),
                child: Text(
                  "NIVEL ${algorithm.nivel}",
                  style: AppTextStyles.code.copyWith(
                    color: Colors.black,
                    fontSize: w * 0.035,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: h * 0.018),

          Row(
            children: [
              Expanded(
                child: _retroBtn(
                  w,
                  h,
                  label: "VISTA PREVIA",
                  color: Colors.white,
                  textColor: Colors.black,
                  border: Colors.black,
                  onTap: onPreview,
                ),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: _retroBtn(
                  w,
                  h,
                  label: "CARGAR",
                  color: const Color(0xFF00C851),
                  textColor: Colors.black,
                  border: Colors.black,
                  onTap: onLoad,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _retroBtn(
    double w,
    double h, {
    required String label,
    required Color color,
    required Color textColor,
    required Color border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.013),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(width: w * 0.008, color: border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.code.copyWith(
            fontSize: w * 0.038,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// SCANLINE PAINTER
// ------------------------------------------------------------
class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) => false;
}
