import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:firebase_database/firebase_database.dart';

class IngresoService {
  static final IngresoService instance = IngresoService();
  final dbRef = FirebaseDatabase.instance.ref("ingresos");

  List<Ingreso>? ingresosCache;

  void clearIngresosCache() {
    ingresosCache = null;
  }

  Ingreso _fromFirebase(String key, Map<dynamic, dynamic> data) {
    return Ingreso(
      id: key,
      idDraftIngreso: data["idDraftIngreso"] ?? "",
      nombreVendedor: data["nombreVendedor"] ?? "",
      detalle: data["detalle"] ?? "",
      fechaCreado: DateTime.parse(data["fechaCreado"]),
      fechaConfirmado: DateTime.parse(data["fechaConfirmado"]),
      materiales:
          (data["materiales"] as List<dynamic>?)
              ?.map(
                (e) =>
                    MaterialEntry(idMaterial: e["idMaterial"], peso: e["peso"]),
              )
              .toList() ??
          [],
      total: data["total"] ?? 0,    
          
    );
  }

  Future<List<Ingreso>> getIngresos() async {
    if (ingresosCache != null) return ingresosCache!;
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final List<Ingreso> ingresos = [];
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (var entry in data.entries) {
        final ingreso = _fromFirebase(
          entry.key,
          Map<String, dynamic>.from(entry.value),
        );
        ingresos.add(ingreso);
      }
      ingresos.sort((a, b) => a.fechaCreado.compareTo(b.fechaCreado));
      ingresosCache = ingresos;
      return ingresos;
    }
    return [];
  }

  Future<List<MaterialEntry>> getIngresoMaterials(String ingresoId) async {
    final snapshot = await dbRef.child(ingresoId).child("materiales").get();
    if (snapshot.exists) {
      final List<MaterialEntry> entries = [];
      for (var e in (snapshot.value as List)) {
        if (e != null) {
          entries.add(
            MaterialEntry(idMaterial: e["idMaterial"], peso: e["peso"]),
          );
        }
      }
      return entries;
    }
    return [];
  }

  Future<void> registerIngreso({
    required String idDraftIngreso,
    required String nombreVendedor,
    required String detalle,
    required DateTime fechaCreado,
    required List<MaterialEntry> materiales,
    required num total,
  }) async {
    final newRef = dbRef.push();
    await newRef.set({
      "idDraftIngreso": idDraftIngreso,
      "nombreVendedor": nombreVendedor,
      "detalle": detalle,
      "fechaCreado": fechaCreado.toIso8601String(),
      "fechaConfirmado": DateTime.now().toIso8601String(),
      "materiales":
          materiales
              .map((e) => {"idMaterial": e.idMaterial, "peso": e.peso})
              .toList(),
      "total": total,
    });
    clearIngresosCache();
  }

  Future<void> deleteIngreso(String id) async {
    await dbRef.child(id).remove();
    clearIngresosCache();
  }

  Future<void> editIngreso(String id, Map<String, dynamic> updateData) async {
    await dbRef.child(id).update(updateData);
    clearIngresosCache();
  }
}
