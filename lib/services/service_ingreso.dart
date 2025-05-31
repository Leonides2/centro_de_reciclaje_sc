import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';

class IngresoService {
  static final IngresoService instance = IngresoService();
  final dbService = DatabaseService.instance;

  List<Ingreso>? ingresosCache;

  void clearIngresosCache() {
    ingresosCache = null;
  }

  Future<List<Ingreso>> getIngresos() async {
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

  // TODO: Cacheo?
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

    final id = await db.insert("Ingreso", {
      "IdDraftIngreso": draftIngreso.id,
      "NombreVendedor": draftIngreso.nombreVendedor,
      "Detalle": draftIngreso.detalle,
      "FechaCreado": draftIngreso.fechaCreado.toString(),
      "FechaConfirmado": DateTime.now().toLocal().toString(),
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
    //MaterialService.instance.clearMaterialsCache();
    clearIngresosCache();
  }
}
