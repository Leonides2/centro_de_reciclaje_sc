import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';

class DraftIngresoService {
  static final DraftIngresoService instance = DraftIngresoService();
  final dbService = DatabaseService.instance;

  List<DraftIngreso>? draftIngresosCache;

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

  Future<List<DraftIngreso>> getDraftIngresos() async {
    if (draftIngresosCache != null) {
      return draftIngresosCache!;
    }

    final db = await dbService.database;
    final List<DraftIngreso> draftIngresos =
        (await db.query(
          "DraftIngreso",
          orderBy: "datetime(FechaCreado) ASC",
        )).map((e) => toDraftIngreso(e)).toList();

    draftIngresosCache = draftIngresos;
    return draftIngresos;
  }

  Future<DraftIngreso> getDraftIngreso(int id) async {
    final db = await dbService.database;
    final draftIngreso = toDraftIngreso(
      (await db.query("DraftIngreso", where: "Id = ?", whereArgs: [id])).first,
    );

    return draftIngreso;
  }

  // TODO: Cacheo?
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
    // TODO: Check for duplicate materials and peso == 0

    final db = await dbService.database;
    final id = await db.insert("DraftIngreso", {
      "NombreVendedor": nombreVendedor,
      "Total": total,
      "Detalle": detalle,
      "FechaCreado": DateTime.now().toLocal().toString(),
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
