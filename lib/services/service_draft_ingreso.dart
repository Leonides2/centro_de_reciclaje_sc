import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

import 'package:sqflite/sqflite.dart';

class DraftIngresoService {
  static final DraftIngresoService instance = DraftIngresoService();
  final dbService = DatabaseService.instance;

  List<DraftIngreso>? draftIngresosCache;
  final dbRef = FirebaseDatabase.instance.ref("draftIngresos");

  void clearDraftIngresosCache() {
    draftIngresosCache = null;
  }

  DraftIngreso toDraftIngreso(Map<String, Object?> e) => DraftIngreso(
        id: e["Id"] as int,
        nombreVendedor: e["NombreVendedor"] as String,
        detalle: e["Detalle"] as String,
        fechaCreado: DateTime.parse(e["FechaCreado"] as String),
        confirmado: (e["Confirmado"] as int) != 0,
        total: e["Total"] as num,
      );

  // Nuevo: Convertir desde Firebase
  DraftIngreso _fromFirebase(String key, Map<dynamic, dynamic> data) {
    return DraftIngreso(
      id: int.tryParse(key) ?? 0,
      nombreVendedor: data["nombreVendedor"] ?? "",
      detalle: data["detalle"] ?? "",
      fechaCreado: DateTime.tryParse(data["fechaCreado"] ?? "") ?? DateTime.now(),
      confirmado: (data["confirmado"] ?? 0) != 0,
      total: data["total"] ?? 0,
    );
  }

  Future<List<DraftIngreso>> getDraftIngresos() async {
    // 1. Intenta obtener de Firebase
    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final List<DraftIngreso> drafts = [];
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        for (var entry in data.entries) {
          final draft = _fromFirebase(entry.key, Map<String, dynamic>.from(entry.value));
          drafts.add(draft);
          await _saveToSQLite(draft);
        }
        drafts.sort((a, b) => b.fechaCreado.compareTo(a.fechaCreado));
        draftIngresosCache = drafts;
        log("DraftIngresos obtenidos de Firebase y sincronizados localmente");
        return drafts;
      }
    } catch (e) {
      log("Error obteniendo DraftIngresos de Firebase: $e");
    }

    // 2. Si falla, usa cache o SQLite
    if (draftIngresosCache != null) {
      return draftIngresosCache!;
    }

    final db = await dbService.database;
    final List<DraftIngreso> draftIngresos =
        (await db.query(
          "DraftIngreso",
          orderBy: "datetime(FechaCreado) DESC",
        )).map((e) => toDraftIngreso(e)).toList();

    draftIngresosCache = draftIngresos;
    return draftIngresos;
  }

  // Guardar draft en SQLite
  Future<void> _saveToSQLite(DraftIngreso draft) async {
    final db = await dbService.database;
    await db.insert(
      "DraftIngreso",
      {
        "Id": draft.id,
        "NombreVendedor": draft.nombreVendedor,
        "Detalle": draft.detalle,
        "FechaCreado": draft.fechaCreado.toString(),
        "Confirmado": draft.confirmado ? 1 : 0,
        "Total": draft.total,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DraftIngreso> getDraftIngreso(int id) async {
    final db = await dbService.database;
    final draftIngreso = toDraftIngreso(
      (await db.query("DraftIngreso", where: "Id = ?", whereArgs: [id])).first,
    );
    return draftIngreso;
  }

  Future<List<MaterialEntry>> getDraftIngresoMaterials(int id) async {
    final db = await dbService.database;
    final entries =
        (await db.query(
              "MaterialDraftIngreso",
              where: "IdDraftIngreso = ?",
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

  Future<void> registerDraftIngreso(
    String nombreVendedor,
    num total,
    String detalle,
    List<MaterialEntry> materiales,
  ) async {
    // 1. Registrar en Firebase
    final newRef = dbRef.push();
    final now = DateTime.now().toLocal();
    await newRef.set({
      "nombreVendedor": nombreVendedor,
      "total": total,
      "detalle": detalle,
      "fechaCreado": now.toString(),
      "confirmado": 0,
      // Puedes agregar materiales aquí si lo deseas
    });

    // 2. Registrar en SQLite
    final db = await dbService.database;
    final id = await db.insert("DraftIngreso", {
      "NombreVendedor": nombreVendedor,
      "Total": total,
      "Detalle": detalle,
      "FechaCreado": now.toString(),
      "Confirmado": 0,
    });

    for (var entry in materiales) {
      await db.insert("MaterialDraftIngreso", {
        "IdMaterial": entry.idMaterial,
        "IdDraftIngreso": id,
        "peso": entry.peso,
      });
    }

    clearDraftIngresosCache();
  }
}