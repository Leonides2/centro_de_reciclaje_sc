import 'dart:developer';

import 'package:centro_de_reciclaje_sc/features/Models/model_egreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:firebase_database/firebase_database.dart';

class EgresoService {
  static final instance = EgresoService();
  final dbRef = FirebaseDatabase.instance.ref("egresos");

  List<Egreso>? egresosCache;

  void clearEgresosCache() {
    egresosCache = null;
  }

  Egreso _fromFirebase(String key, Map<dynamic, dynamic> data) {
    return Egreso(
      id: key,
      nombreCliente: data["nombreCliente"] ?? "",
      total: data["total"] ?? 0,
      detalle: data["detalle"] ?? "",
      fechaCreado: DateTime.parse(data["fechaCreado"]),
    );
  }

  Future<List<Egreso>> getEgresos() async {
    if (egresosCache != null) {
      return egresosCache!;
    }
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final List<Egreso> egresos = [];
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (var entry in data.entries) {
        final egreso = _fromFirebase(entry.key, Map<String, dynamic>.from(entry.value));
        egresos.add(egreso);
      }
      egresos.sort((a, b) => b.fechaCreado.compareTo(a.fechaCreado));
      egresosCache = egresos;
      return egresos;
    }
    return [];
  }

  Future<List<MaterialEntry>> getEgresoMaterials(String egresoId) async {
    final snapshot = await dbRef.child(egresoId).child("materiales").get();
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

  Future<void> registerEgreso(
    String nombreCliente,
    num total,
    String detalle,
    List<MaterialEntry> materialEntries,
  ) async {
    final materialService = MaterialService.instance;

    // Validar stock antes de registrar
    for (var entry in materialEntries) {
      final material = await materialService.getMaterial(entry.idMaterial);
      if (material == null || material.stock - entry.peso < 0) {
        throw "No hay stock suficiente para el material ${material?.nombre ?? ''} (Stock actual: ${material?.stock ?? 0})";
      }
    }

    // Registrar egreso en Firebase
    final newRef = dbRef.push();
    await newRef.set({
      "nombreCliente": nombreCliente,
      "total": total,
      "detalle": detalle,
      "fechaCreado": DateTime.now().toIso8601String(),
      "materiales": materialEntries
          .map((e) => {
                "idMaterial": e.idMaterial,
                "peso": e.peso,
              })
          .toList(),
    });

    // Actualizar stock de materiales
    for (var entry in materialEntries) {
      final material = await materialService.getMaterial(entry.idMaterial);
      await materialService.editMaterial(
        material!.id,
        material.nombre,
        material.precioKilo,
        material.stock - entry.peso,
      );
    }

    materialService.clearMaterialsCache();
    clearEgresosCache();
  }

  Future<void> deleteEgreso(String id) async {
    await dbRef.child(id).remove();
    clearEgresosCache();
  }
}