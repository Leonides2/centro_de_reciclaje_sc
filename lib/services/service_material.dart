import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';

class MaterialService {
  static final MaterialService instance = MaterialService();
  final dbService = DatabaseService.instance;

  Future<List<RecyclingMaterial>> getMaterials() async {
    final db = await dbService.database;
    final materials =
        (await db.query("Material"))
            .map(
              (e) => RecyclingMaterial(
                id: e["Id"] as int,
                nombre: e["Nombre"] as String,
                precioKilo: e["PrecioKilo"] as num,
                stock: e["Stock"] as num,
              ),
            )
            .toList();

    return materials;
  }

  void registerMaterial(nombre, precioKilo) async {
    final db = await dbService.database;
    final materialId = await db.insert("Material", {
      "nombre": nombre,
      "precioKilo": precioKilo,
      "stock": 0,
    });
  }
}
