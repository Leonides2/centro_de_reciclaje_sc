import 'dart:developer';

import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';

class MaterialService {
  static final MaterialService instance = MaterialService();
  final dbService = DatabaseService.instance;

  List<RecyclingMaterial>? materialsCache;
  Map<int, RecyclingMaterial> indexedMaterialsCache = {};

  void clearMaterialsCache() {
    materialsCache = null;
    indexedMaterialsCache = {};
  }

  RecyclingMaterial _toMaterial(Map<String, Object?> e) => RecyclingMaterial(
    id: e["Id"] as int,
    nombre: e["Nombre"] as String,
    precioKilo: e["PrecioKilo"] as num,
    stock: e["Stock"] as num,
  );

  Future<List<RecyclingMaterial>> getMaterials() async {
    if (materialsCache != null) {
      log("Returning from cache");
      return materialsCache!;
    }

    final db = await dbService.database;
    final materials = (await db.query("Material")).map(_toMaterial).toList();
    log("Setting cache");
    materialsCache = materials;
    return materials;
  }

  Future<RecyclingMaterial> getMaterial(int id) async {
    if (indexedMaterialsCache.containsKey(id)) {
      return indexedMaterialsCache[id]!;
    }

    final db = await dbService.database;

    final material = _toMaterial(
      (await db.query("Material", where: "Id = ?", whereArgs: [id])).first,
    );

    indexedMaterialsCache[id] = material;
    return material;
  }

  Future<void> registerMaterial(String nombre, num precioKilo) async {
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

    clearMaterialsCache();
  }

  Future<void> editMaterial(
    int id,
    String nombre,
    num precioKilo,
    num stock,
  ) async {
    await editMaterialNoClearCache(id, nombre, precioKilo, stock);

    clearMaterialsCache();
  }

  Future<void> editMaterialNoClearCache(
    int id,
    String nombre,
    num precioKilo,
    num stock,
  ) async {
    final db = await dbService.database;
    await db.update(
      "Material",
      {"Nombre": nombre, "PrecioKilo": precioKilo, "Stock": stock},
      where: "Id = ?",
      whereArgs: [id],
    );
  }
}
