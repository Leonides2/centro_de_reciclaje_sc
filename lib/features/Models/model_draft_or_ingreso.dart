sealed class DraftOrIngreso {}

class Ingreso extends DraftOrIngreso {
  Ingreso({
    required this.id,
    required this.idDraftIngreso,
    required this.nombreVendedor,
    required this.detalle,
    required this.fechaConfirmado,
    required this.fechaCreado,
  });

  final int id;
  final int idDraftIngreso;
  final String nombreVendedor;
  final String detalle;
  final DateTime fechaCreado;
  final DateTime fechaConfirmado;
}

class DraftIngreso extends DraftOrIngreso {
  DraftIngreso({
    required this.id,
    required this.nombreVendedor,
    required this.detalle,
    required this.fechaCreado,
    required this.confirmado,
    required this.total,
  });

  final int id;
  final String nombreVendedor;
  final String detalle;
  final DateTime fechaCreado;
  final num total;
  final bool confirmado;
}
