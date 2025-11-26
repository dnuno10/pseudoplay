import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/block_draggable.dart';
import '../components/block_drop_area.dart';
import '../managers/blocks_manager.dart';
import '../models/block_model.dart';
import '../models/block_palette_item.dart';
import '../models/game_mode.dart';
import '../provider/declared_variables_provider.dart';
import '../provider/editor_provider.dart';
import '../provider/user_preferences_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/block_dialogs.dart';
import '../widgets/retro_snackbar.dart';

class BlocksModeView extends ConsumerStatefulWidget {
  const BlocksModeView({super.key});

  @override
  ConsumerState<BlocksModeView> createState() => _BlocksModeViewState();
}

class _BlocksModeViewState extends ConsumerState<BlocksModeView>
    with TickerProviderStateMixin {
  late TabController _tabs;
  late ScrollController _scroll;

  late AnimationController _crtController;
  late final UserPreferencesNotifier _prefsNotifier;

  final _categorias = ['Variables', 'Entrada/Salida', 'Lógica'];

  late Map<String, List<BlockPaletteItem>> _paleta;
  late Map<String, BlockPaletteItem> _index;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _categorias.length, vsync: this)
      ..addListener(() => setState(() {}));
    _scroll = ScrollController();

    _crtController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _paleta = _buildPalette();

    _index = {
      for (final group in _paleta.values)
        for (final item in group) item.id: item,
    };

    _prefsNotifier = ref.read(userPreferencesProvider.notifier);
    _prefsNotifier.startSession(GameMode.blocks);
  }

  @override
  void dispose() {
    _prefsNotifier.stopSession(GameMode.blocks);
    _tabs.dispose();
    _scroll.dispose();
    _crtController.dispose();
    super.dispose();
  }

  Map<String, List<BlockPaletteItem>> _buildPalette() {
    return {
      'Variables': [
        BlockPaletteItem(
          id: 'variable',
          titulo: 'Declarar variable',
          descripcion: 'Declara una variable',
          color: const Color(0xFF2962FF),
          icono: Icons.code,
          categoria: 'Variables',
        ),
        BlockPaletteItem(
          id: 'asignacion',
          titulo: 'Asignar valor',
          descripcion: 'Asigna un valor',
          color: const Color(0xFF9C27B0),
          icono: Icons.edit,
          categoria: 'Variables',
        ),
      ],
      'Entrada/Salida': [
        BlockPaletteItem(
          id: 'leer',
          titulo: 'Leer',
          descripcion: 'Solicita un valor',
          color: const Color(0xFF00C851),
          icono: Icons.input,
          categoria: 'Entrada/Salida',
        ),
        BlockPaletteItem(
          id: 'escribir',
          titulo: 'Escribir',
          descripcion: 'Imprime en pantalla',
          color: const Color(0xFFFF8800),
          icono: Icons.output,
          categoria: 'Entrada/Salida',
        ),
      ],
      'Lógica': [
        BlockPaletteItem(
          id: 'si',
          titulo: 'SI',
          descripcion: 'Condición',
          color: const Color(0xFF8E24AA),
          icono: Icons.alt_route,
          categoria: 'Lógica',
        ),
        BlockPaletteItem(
          id: 'sino',
          titulo: 'SINO',
          descripcion: 'Alternativa',
          color: const Color(0xFF5E1780),
          icono: Icons.call_split,
          categoria: 'Lógica',
        ),
        BlockPaletteItem(
          id: 'finsi',
          titulo: 'FinSi',
          descripcion: 'Cierra condición',
          color: const Color(0xFF5E1780),
          icono: Icons.keyboard_tab,
          categoria: 'Lógica',
        ),
        BlockPaletteItem(
          id: 'repite',
          titulo: 'Repite',
          descripcion: 'Bucle',
          color: const Color(0xFF6A9EFF),
          icono: Icons.repeat,
          categoria: 'Lógica',
        ),
        BlockPaletteItem(
          id: 'finrepite',
          titulo: 'FinRepite',
          descripcion: 'Cierra bucle',
          color: const Color(0xFF6A9EFF),
          icono: Icons.stop_circle,
          categoria: 'Lógica',
        ),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final blocks = ref.watch(blocksManagerProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final isWide = w > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDB),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RetroTexturePainter())),

          _scanlines(w, h),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(w * 0.06, h * 0.01, w * 0.06, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(w),

                  SizedBox(height: h * 0.02),
                  Text(
                    "Modo por\nbloques",
                    style: AppTextStyles.title.copyWith(
                      fontSize: w * 0.095,
                      height: 1.05,
                      color: AppColors.purple,
                    ),
                  ),

                  SizedBox(height: h * 0.02),
                  _tabsRetro(w, h),

                  SizedBox(height: h * 0.02),

                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: h * 0.6,
                                child: _paletteView(w, h),
                              ),
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(child: _dropZone(w, h, blocks)),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              height: h * 0.30,
                              child: _paletteView(w, h),
                            ),
                            SizedBox(height: h * 0.02),
                            _dropZone(w, h, blocks),
                          ],
                        ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: w * 0.06,
            right: w * 0.06,
            child: _convertButtonFloating(w, h, blocks.isNotEmpty),
          ),
        ],
      ),
    );
  }

  Widget _scanlines(double w, double h) {
    return AnimatedBuilder(
      animation: _crtController,
      builder: (_, __) {
        return Opacity(
          opacity: 0.04 + _crtController.value * 0.03,
          child: CustomPaint(size: Size(w, h), painter: _ScanlinePainter()),
        );
      },
    );
  }

  Widget _header(double w) {
    return GestureDetector(
      onTap: () => context.go('/menu'),
      child: Row(
        children: [
          Icon(Icons.arrow_back_ios, size: w * 0.07, color: AppColors.purple),
          SizedBox(width: w * 0.02),
          Text(
            "Regresar",
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.045,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabsRetro(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.015),
      decoration: BoxDecoration(
        color: AppColors.purple,
        border: Border.all(width: w * 0.01, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabs,
        indicator: BoxDecoration(
          color: const Color(0xFF00C851),
          border: Border.all(width: w * 0.009, color: Colors.black),
        ),
        labelStyle: AppTextStyles.code.copyWith(
          fontSize: w * 0.032,
          color: Colors.white,
        ),
        unselectedLabelStyle: AppTextStyles.code.copyWith(
          fontSize: w * 0.032,
          color: Colors.white70,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: _categorias.map((e) {
          return SizedBox(
            height: h * 0.045,
            child: Center(child: Text(e.toUpperCase())),
          );
        }).toList(),
      ),
    );
  }

  Widget _paletteView(double w, double h) {
    final tab = _categorias[_tabs.index];
    final items = _paleta[tab]!;

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DCC0),
        border: Border.all(width: w * 0.01, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Scrollbar(
        controller: _scroll,
        radius: Radius.circular(w * 0.02),
        child: ListView.separated(
          controller: _scroll,
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: h * 0.015),
          itemBuilder: (_, i) => BlockDraggable(item: items[i], w: w, h: h),
        ),
      ),
    );
  }

  Widget _dropZone(double w, double h, List<BlockModel> blocks) {
    return BlockDropArea(
      w: w,
      h: h,
      blocks: blocks,
      colorBuilder: (b) {
        return _index[b.tipo]?.color ?? Colors.deepPurple;
      },
      onClear: () {
        ref.read(blocksManagerProvider.notifier).reset();
        ref.read(declaredVariablesProvider.notifier).clear();
      },
      onRemove: (i) =>
          ref.read(blocksManagerProvider.notifier).eliminarBloque(i),
      onBlockDropped: (context, item) async {
        final declaredVars = ref.read(declaredVariablesProvider);
        Map<String, dynamic>? data;

        switch (item.id) {
          case 'variable':
            data = await BlockDialogs.pedirVariable(context, declaredVars);
            if (data != null) {
              ref
                  .read(declaredVariablesProvider.notifier)
                  .addVariable(data['nombre']);
            }
            break;
          case 'asignacion':
            if (declaredVars.isEmpty) {
              _showError(context, 'Primero debes declarar una variable');
              return;
            }
            data = await BlockDialogs.pedirAsignacion(context, declaredVars);
            break;
          case 'leer':
            if (declaredVars.isEmpty) {
              _showError(context, 'Primero debes declarar una variable');
              return;
            }
            data = await BlockDialogs.pedirLeer(context, declaredVars);
            break;
          case 'escribir':
            data = await BlockDialogs.pedirEscribir(context, declaredVars);
            break;
          case 'si':
            data = await BlockDialogs.pedirCondicion(context, declaredVars);
            break;
          case 'repite':
            data = await BlockDialogs.pedirRepeticiones(context, declaredVars);
            break;
          default:
            data = {};
        }

        if (!mounted) {
          return;
        }

        if (data == null &&
            item.id != 'sino' &&
            item.id != 'finsi' &&
            item.id != 'finrepite') {
          return;
        }

        String display = _buildDisplayText(item.id, data);

        ref
            .read(blocksManagerProvider.notifier)
            .agregarBloque(item.id, display, data: data);
      },
    );
  }

  String _buildDisplayText(String tipo, Map<String, dynamic>? data) {
    switch (tipo) {
      case 'variable':
        return 'VARIABLE: ${data!['nombre']} = ${data['valor']}';
      case 'asignacion':
        return 'ASIGNACIÓN: ${data!['var']} = ${data['expr']}';
      case 'leer':
        return 'LEER: ${data!['var']}';
      case 'escribir':
        return 'ESCRIBIR: ${data!['valor']}';
      case 'si':
        return 'SI: ${data!['condicion']}';
      case 'sino':
        return 'SINO';
      case 'finsi':
        return 'FIN SI';
      case 'repite':
        return 'REPITE: ${data!['veces']}';
      case 'finrepite':
        return 'FIN REPITE';
      default:
        return tipo.toUpperCase();
    }
  }

  Widget _convertButtonFloating(double w, double h, bool enabled) {
    return GestureDetector(
      onTap: enabled ? _convert : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: h * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xFF00C851),
            border: Border.all(width: w * 0.012, color: Colors.black),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                offset: const Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            "CONVERTIR A CÓDIGO",
            style: AppTextStyles.code.copyWith(
              fontSize: w * 0.05,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _convert() {
    final codigo = ref
        .read(blocksManagerProvider.notifier)
        .convertirAPseudocodigo();

    if (codigo.trim().isEmpty) return;

    ref.read(editorProvider.notifier).updateText(codigo);
    context.go('/editor');
  }

  void _showError(BuildContext context, String msg) {
    RetroSnackBar.show(
      context,
      message: msg,
      tone: RetroSnackTone.error,
      icon: Icons.warning_rounded,
    );
  }
}

class _RetroTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.02)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_RetroTexturePainter oldDelegate) => false;
}

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
