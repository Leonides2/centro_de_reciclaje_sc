import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';


sealed class DraftOrIngreso {}

class Ingreso extends DraftOrIngreso {
  Ingreso({
    required this.id,
    required this.idDraftIngreso,
    required this.nombreVendedor,
    required this.detalle,
    required this.fechaConfirmado,
    required this.fechaCreado,
    required this.materiales,
    required this.total, // <-- Agrega esto
  });

  final String id;
  final String idDraftIngreso;
  final String nombreVendedor;
  final String detalle;
  final DateTime fechaCreado;
  final DateTime fechaConfirmado;
  final List<MaterialEntry> materiales;
  final num total; 
}

class DraftIngreso extends DraftOrIngreso {
  DraftIngreso({
    required this.id,
    required this.nombreVendedor,
    required this.detalle,
    required this.fechaCreado,
    required this.confirmado,
    required this.total,
    required this.materiales
  });

  final String id;
  final String nombreVendedor;
  final String detalle;
  final DateTime fechaCreado;
  final num total;
  final bool confirmado;
  final List<MaterialEntry> materiales;
}
