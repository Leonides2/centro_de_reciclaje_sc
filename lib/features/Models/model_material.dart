class RecyclingMaterial {
  final int id;
  final String nombre;
  final num precioKilo;
  final num stock;

  RecyclingMaterial({
    required this.id,
    required this.nombre,
    required this.precioKilo,
    required this.stock,
  });

  factory RecyclingMaterial.fromMap(Map<String, dynamic> map) {
    return RecyclingMaterial(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      nombre: map['nombre'],
      precioKilo: map['precioKilo'],
      stock: map['stock'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precioKilo': precioKilo,
      'stock': stock,
    };
  }
}