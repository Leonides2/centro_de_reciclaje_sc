import 'dart:developer';

import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';

class MaterialService {
  static final MaterialService instance = MaterialService();
  final dbService = DatabaseService.instance;

  List<RecyclingMaterial>? materialsCache;

  void clearMaterialsCache() {
    materialsCache = null;
  }

  Future<List<RecyclingMaterial>> getMaterials() async {
    if (materialsCache != null) {
      log("Returning from cache");
      return materialsCache!;
    }

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
    log("Setting cache");
    materialsCache = materials;
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

  void editMaterial(int id, String nombre, num precioKilo, num stock) async {
    final db = await dbService.database;
    await db.update(
      "Material",
      {"Nombre": nombre, "PrecioKilo": precioKilo, "Stock": stock},
      where: "Id = ?",
      whereArgs: [id],
    );
  }
}
