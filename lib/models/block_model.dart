class BlockModel {
  final String tipo;
  final String display;
  final Map<String, dynamic>? data;

  BlockModel({required this.tipo, required this.display, this.data});

  @override
  String toString() => "$tipo -> $data";
}
