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

  Future<List<DraftIngreso>> getDraftIngresos() async {
    if (draftIngresosCache != null) {
      return draftIngresosCache!;
    }

    final db = await dbService.database;
    final draftIngresos =
        (await db.query("DraftIngreso"))
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
            .toList();

    draftIngresos.sort((a, b) {
      if (a.confirmado == b.confirmado) {
        return -a.fechaCreado.compareTo(b.fechaCreado);
      }
      if (a.confirmado) {
        return 1;
      }
      return -1;
    });

    draftIngresosCache = draftIngresos;
    return draftIngresos;
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
