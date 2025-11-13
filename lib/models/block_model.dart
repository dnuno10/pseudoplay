class BlockModel {
  final String tipo;
  final Map<String, dynamic>? data;

  BlockModel({required this.tipo, this.data});

  @override
  String toString() => "$tipo -> $data";
}
