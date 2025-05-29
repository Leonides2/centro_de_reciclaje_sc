import 'dart:developer';

import 'package:centro_de_reciclaje_sc/features/Models/model_egreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';

class EgresoService {
  final dbService = DatabaseService.instance;
  static final instance = EgresoService();

  List<Egreso>? egresosCache;
  Map<int, Egreso> indexedEgresosCache = {};

  void _clearEgresosCache() {
    egresosCache = null;
    indexedEgresosCache = {};
  }

  Egreso toEgreso(Map<String, Object?> e) => Egreso(
    id: e["Id"] as int,
    nombreCliente: e["NombreVendedor"] as String,
    total: e["Total"] as num,
    detalle: e["Detalle"] as String,
    fechaCreado: DateTime.parse(e["FechaCreado"] as String),
  );

  Future<List<Egreso>> getEgresos() async {
    if (egresosCache != null) {
      return egresosCache!;
    }

    final db = await dbService.database;
    final egresos = (await db.query("Egreso")).map(toEgreso).toList();

    egresosCache = egresos;
    log(egresos.toString());
    return egresos;
  }

  Future<Egreso> getEgreso(int id) async {
    if (indexedEgresosCache.containsKey(id)) {
      return indexedEgresosCache[id]!;
    }

    final db = await dbService.database;
    final egreso = toEgreso(
      (await db.query("Egreso", where: "Id = ?", whereArgs: [id])).first,
    );

    indexedEgresosCache[id] = egreso;
    return egreso;
  }

  // TODO: Cacheo
  Future<List<MaterialEntry>> getEgresoMaterials(int idEgreso) async {
    final db = await dbService.database;
    final entries =
        (await db.query(
              "MaterialEgreso",
              where: "IdEgreso = ?",
              whereArgs: [idEgreso],
            ))
            .map(
              (e) => MaterialEntry(
                idMaterial: e["IdMaterial"] as int,
                peso: e["Peso"] as num,
              ),
            )
            .toList();

    return entries;
  }

  Future<void> registerEgreso(
    String nombreCliente,
    num total,
    String detalle,
    List<MaterialEntry> materialEntries,
  ) async {
    final db = await dbService.database;
    final materialService = MaterialService.instance;

    // TODO: Change to a transaction???
    for (var entry in materialEntries) {
      final material = await materialService.getMaterial(entry.idMaterial);

      if (material.stock - entry.peso < 0) {
        throw "No hay stock suficiente para el material ${material.nombre}";
      }
    }

    for (var entry in materialEntries) {
      final material = await materialService.getMaterial(entry.idMaterial);

      materialService.editMaterialNoClearCache(
        material.id,
        material.nombre,
        material.precioKilo,
        material.stock - entry.peso,
      );
    }

    await db.insert("Egreso", {
      "nombreVendedor": nombreCliente,
      "total": total,
      "detalle": detalle,
      "fechaCreado": DateTime.now().toLocal().toString(),
    });

    materialService.clearMaterialsCache();
    _clearEgresosCache();
  }
}
