import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_ingreso.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

import 'package:sqflite/sqflite.dart';

class IngresoService {
  static final IngresoService instance = IngresoService();
  final dbService = DatabaseService.instance;

  List<Ingreso>? ingresosCache;
  final dbRef = FirebaseDatabase.instance.ref("ingresos");

  void clearIngresosCache() {
    ingresosCache = null;
  }

  Future<List<Ingreso>> getIngresos() async {
    // 1. Intenta obtener de Firebase
    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final List<Ingreso> ingresos = [];
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        for (var entry in data.entries) {
          final ingresoData = Map<String, dynamic>.from(entry.value);
          final ingreso = Ingreso(
            id: int.tryParse(entry.key) ?? 0,
            idDraftIngreso: ingresoData["idDraftIngreso"] ?? 0,
            nombreVendedor: ingresoData["nombreVendedor"] ?? "",
            detalle: ingresoData["detalle"] ?? "",
            fechaCreado: DateTime.tryParse(ingresoData["fechaCreado"] ?? "") ?? DateTime.now(),
            fechaConfirmado: DateTime.tryParse(ingresoData["fechaConfirmado"] ?? "") ?? DateTime.now(),
          );
          ingresos.add(ingreso);
          await _saveToSQLite(ingreso);
        }
        ingresos.sort((a, b) => a.fechaCreado.compareTo(b.fechaCreado));
        ingresosCache = ingresos;
        log("Ingresos obtenidos de Firebase y sincronizados localmente");
        return ingresos;
      }
    } catch (e) {
      log("Error obteniendo ingresos de Firebase: $e");
    }

    // 2. Si falla, usa cache o SQLite
    if (ingresosCache != null) {
      return ingresosCache!;
    }

    final db = await dbService.database;
    final ingresos =
        (await db.query("Ingreso", orderBy: "datetime(FechaConfirmado) DESC"))
            .map(
              (e) => Ingreso(
                id: e["Id"] as int,
                idDraftIngreso: e["IdDraftIngreso"] as int,
                nombreVendedor: e["NombreVendedor"] as String,
                detalle: e["Detalle"] as String,
                fechaCreado: DateTime.parse(e["FechaCreado"] as String),
                fechaConfirmado: DateTime.parse(e["FechaConfirmado"] as String),
              ),
            )
            .toList();

    ingresos.sort((a, b) => a.fechaCreado.compareTo(b.fechaCreado));
    ingresosCache = ingresos;
    return ingresos;
  }

  // Guardar ingreso en SQLite
  Future<void> _saveToSQLite(Ingreso ingreso) async {
    final db = await dbService.database;
    await db.insert(
      "Ingreso",
      {
        "Id": ingreso.id,
        "IdDraftIngreso": ingreso.idDraftIngreso,
        "NombreVendedor": ingreso.nombreVendedor,
        "Detalle": ingreso.detalle,
        "FechaCreado": ingreso.fechaCreado.toString(),
        "FechaConfirmado": ingreso.fechaConfirmado.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MaterialEntry>> geIngresoMaterials(int id) async {
    final db = await dbService.database;
    final entries =
        (await db.query(
              "MaterialIngreso",
              where: "IdIngreso = ?",
              whereArgs: [id],
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

  Future<void> registerIngreso(
    int idDraftIngreso,
    List<MaterialEntry> materiales,
  ) async {
    final db = await dbService.database;

    final draftIngreso =
        (await db.query(
              "DraftIngreso",
              where: "Id = ?",
              whereArgs: [idDraftIngreso],
            ))
            .map(
              (e) => DraftIngreso(
                id: e["Id"] as int,
                nombreVendedor: e["NombreVendedor"] as String,
                detalle: e["Detalle"] as String,
                fechaCreado: DateTime.parse(e["FechaCreado"] as String),
                confirmado: (e["Confirmado"] as int) != 0,
                total: e["Total"] as num,
              ),
            )
            .first;

    // 1. Registrar en Firebase
    final newRef = dbRef.push();
    final now = DateTime.now().toLocal();
    await newRef.set({
      "idDraftIngreso": draftIngreso.id,
      "nombreVendedor": draftIngreso.nombreVendedor,
      "detalle": draftIngreso.detalle,
      "fechaCreado": draftIngreso.fechaCreado.toString(),
      "fechaConfirmado": now.toString(),
      // Puedes agregar materiales aquí si lo deseas
    });

    // 2. Registrar en SQLite
    final id = await db.insert("Ingreso", {
      "IdDraftIngreso": draftIngreso.id,
      "NombreVendedor": draftIngreso.nombreVendedor,
      "Detalle": draftIngreso.detalle,
      "FechaCreado": draftIngreso.fechaCreado.toString(),
      "FechaConfirmado": now.toString(),
    });

    for (var entry in materiales) {
      await db.insert("MaterialIngreso", {
        "IdMaterial": entry.idMaterial,
        "IdIngreso": id,
        "Peso": entry.peso,
      });

      await db.rawUpdate(
        "UPDATE Material SET Stock = Stock + ? WHERE Id = ?;",
        [entry.peso, entry.idMaterial],
      );
    }

    await db.update(
      "DraftIngreso",
      where: "Id = ?",
      whereArgs: [idDraftIngreso],
      {"Confirmado": true},
    );

    DraftIngresoService.instance.clearDraftIngresosCache();
    clearIngresosCache();
  }
}