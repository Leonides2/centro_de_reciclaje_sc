import 'dart:developer';

import 'package:centro_de_reciclaje_sc/features/Models/model_egreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';

class EgresoService {
  final dbService = DatabaseService.instance;
  static final instance = EgresoService();

  List<Egreso>? egresosCache;
  Map<int, Egreso> indexedEgresosCache = {};

  final dbRef = FirebaseDatabase.instance.ref("egresos");

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

  // Obtener egresos desde Firebase y sincronizar con SQLite
  Future<List<Egreso>> getEgresos() async {
    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final List<Egreso> egresos = [];
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        for (var entry in data.entries) {
          final egresoData = Map<String, dynamic>.from(entry.value);
          final egreso = Egreso(
            id: int.tryParse(entry.key) ?? 0,
            nombreCliente: egresoData["nombreVendedor"] ?? "",
            total: egresoData["total"] ?? 0,
            detalle: egresoData["detalle"] ?? "",
            fechaCreado: DateTime.tryParse(egresoData["fechaCreado"] ?? "") ?? DateTime.now(),
          );
          egresos.add(egreso);
          await _saveToSQLite(egreso);
        }
        egresos.sort((a, b) => b.fechaCreado.compareTo(a.fechaCreado));
        egresosCache = egresos;
        log("Egresos obtenidos de Firebase y sincronizados localmente");
        return egresos;
      }
    } catch (e) {
      log("Error obteniendo egresos de Firebase: $e");
    }

    // Si falla, usa cache o SQLite
    if (egresosCache != null) {
      return egresosCache!;
    }

    final db = await dbService.database;
    final egresos =
        (await db.query(
          "Egreso",
          orderBy: "datetime(FechaCreado) DESC",
        )).map(toEgreso).toList();

    egresosCache = egresos;
    return egresos;
  }

  // Guardar egreso en SQLite
  Future<void> _saveToSQLite(Egreso egreso) async {
    final db = await dbService.database;
    await db.insert(
      "Egreso",
      {
        "Id": egreso.id,
        "NombreVendedor": egreso.nombreCliente,
        "Total": egreso.total,
        "Detalle": egreso.detalle,
        "FechaCreado": egreso.fechaCreado.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

    // Validar stock antes de registrar
    for (var entry in materialEntries) {
      final material = await materialService.getMaterial(entry.idMaterial);
      if (material.stock - entry.peso < 0) {
        throw "No hay stock suficiente para el material ${material.nombre} (Stock actual: ${material.stock})";
      }
    }

    // 1. Registrar en Firebase
    final newRef = dbRef.push();
    final now = DateTime.now().toLocal();
    await newRef.set({
      "nombreVendedor": nombreCliente,
      "total": total,
      "detalle": detalle,
      "fechaCreado": now.toString(),
      // Puedes agregar los materiales aquí si lo deseas
    });

    // 2. Registrar en SQLite
    final idEgreso = await db.insert("Egreso", {
      "NombreVendedor": nombreCliente,
      "Total": total,
      "Detalle": detalle,
      "FechaCreado": now.toString(),
    });

    for (var entry in materialEntries) {
      final material = await materialService.getMaterial(entry.idMaterial);

      await materialService.editMaterialNoClearCache(
        material.id,
        material.nombre,
        material.precioKilo,
        material.stock - entry.peso,
      );

      await db.insert("MaterialEgreso", {
        "IdMaterial": entry.idMaterial,
        "IdEgreso": idEgreso,
        "Peso": entry.peso,
      });
    }

    materialService.clearMaterialsCache();
    _clearEgresosCache();
  }
}