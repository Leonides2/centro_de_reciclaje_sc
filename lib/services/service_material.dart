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

  void registerMaterial(String nombre, num precioKilo) async {
    if (nombre.isEmpty) {
      throw Exception("El campo \"nombre\" debe no estar vacío");
    }

    if (precioKilo <= 0) {
      throw Exception("El campo \"precioKilo\" debe no estar vacío");
    }

    final db = await dbService.database;
    await db.insert("Material", {
      "nombre": nombre,
      "precioKilo": precioKilo,
      "stock": 0,
    });
  }
}
