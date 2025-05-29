class Egreso {
  Egreso({
    required this.id,
    required this.nombreCliente,
    required this.total,
    required this.detalle,
    required this.fechaCreado,
  });

  final int id;
  final String nombreCliente;
  final num total;
  final String detalle;
  final DateTime fechaCreado;
}
