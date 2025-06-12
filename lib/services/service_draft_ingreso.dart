import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:firebase_database/firebase_database.dart';

class DraftIngresoService {
  static final DraftIngresoService instance = DraftIngresoService();
  final dbRef = FirebaseDatabase.instance.ref("draftIngresos");

  List<DraftIngreso>? draftIngresosCache;

  void clearDraftIngresosCache() {
    draftIngresosCache = null;
  }

  DraftIngreso _fromFirebase(String key, Map<dynamic, dynamic> data) {
    return DraftIngreso(
      id: key,
      nombreVendedor: data["nombreVendedor"] ?? "",
      detalle: data["detalle"] ?? "",
      fechaCreado: DateTime.parse(data["fechaCreado"]),
      confirmado: data["confirmado"] ?? false,
      total: data["total"] ?? 0,
      materiales: (data["materiales"] as List<dynamic>?)
          ?.map((e) => MaterialEntry(
                idMaterial: e["idMaterial"],
                peso: e["peso"],
              ))
          .toList() ?? [],
    );
  }

  Future<List<DraftIngreso>> getDraftIngresos() async {
    if (draftIngresosCache != null) return draftIngresosCache!;
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final List<DraftIngreso> draftIngresos = [];
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (var entry in data.entries) {
        final draftIngreso = _fromFirebase(entry.key, Map<String, dynamic>.from(entry.value));
        draftIngresos.add(draftIngreso);
      }
      draftIngresos.sort((a, b) => b.fechaCreado.compareTo(a.fechaCreado));
      draftIngresosCache = draftIngresos;
      return draftIngresos;
    }
    return [];
  }

  Future<DraftIngreso?> getDraftIngreso(String id) async {
    final snapshot = await dbRef.child(id).get();
    if (snapshot.exists) {
      return _fromFirebase(id, Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  Future<List<MaterialEntry>> getDraftIngresoMaterials(String draftId) async {
    final snapshot = await dbRef.child(draftId).child("materiales").get();
    if (snapshot.exists) {
      final List<MaterialEntry> entries = [];
      for (var e in (snapshot.value as List)) {
        if (e != null) {
          entries.add(MaterialEntry(
            idMaterial: e["idMaterial"],
            peso: e["peso"],
          ));
        }
      }
      return entries;
    }
    return [];
  }

  Future<void> registerDraftIngreso({
    required String nombreVendedor,
    required num total,
    required String detalle,
    required List<MaterialEntry> materiales,
  }) async {
    final newRef = dbRef.push();
    await newRef.set({
      "nombreVendedor": nombreVendedor,
      "detalle": detalle,
      "fechaCreado": DateTime.now().toIso8601String(),
      "confirmado": false,
      "total": total,
      "materiales": materiales
          .map((e) => {
                "idMaterial": e.idMaterial,
                "peso": e.peso,
              })
          .toList(),
    });
    clearDraftIngresosCache();
  }

  Future<void> confirmarDraftIngreso(DraftIngreso draft) async {
  // 1. Crear el ingreso confirmado
  await IngresoService.instance.registerIngreso(
    idDraftIngreso: draft.id,
    nombreVendedor: draft.nombreVendedor,
    detalle: draft.detalle,
    fechaCreado: draft.fechaCreado,
    materiales: draft.materiales,
    total: draft.total,
  );

  // 2. Actualizar stock de materiales
  for (final entry in draft.materiales) {
    await MaterialService.instance.incrementStock(entry.idMaterial, entry.peso);
  }

  // 3. Eliminar el draft
  await deleteDraftIngreso(draft.id);
}

  Future<void> deleteDraftIngreso(String id) async {
    await dbRef.child(id).remove();
    clearDraftIngresosCache();
  }
}