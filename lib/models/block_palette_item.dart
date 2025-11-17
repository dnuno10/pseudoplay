import 'package:flutter/material.dart';

class BlockPaletteItem {
  final String id;
  final String titulo;
  final String descripcion;
  final Color color;
  final IconData icono;
  final String categoria;

  const BlockPaletteItem({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.icono,
    required this.categoria,
  });
}
