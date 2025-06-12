import 'dart:developer';

import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:firebase_database/firebase_database.dart';

class MaterialService {
  static final MaterialService instance = MaterialService();
  final dbRef = FirebaseDatabase.instance.ref("materiales");

  List<RecyclingMaterial>? materialsCache;
  Map<String, RecyclingMaterial> indexedMaterialsCache = {};

  void clearMaterialsCache() {
    materialsCache = null;
    indexedMaterialsCache = {};
  }

  RecyclingMaterial _fromFirebase(String key, Map<dynamic, dynamic> data) {
    return RecyclingMaterial(
      id: key, // Cambia tu modelo a String id si es necesario
      nombre: data["nombre"] ?? "",
      precioKilo: data["precioKilo"] ?? 0,
      stock: data["stock"] ?? 0,
    );
  }

  Future<List<RecyclingMaterial>> getMaterials() async {
    if (materialsCache != null) {
      log("Returning from cache");
      return materialsCache!;
    }
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final List<RecyclingMaterial> materials = [];
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (var entry in data.entries) {
        final material = _fromFirebase(
          entry.key,
          Map<String, dynamic>.from(entry.value),
        );
        materials.add(material);
        indexedMaterialsCache[entry.key] = material;
      }
      materialsCache = materials;
      return materials;
    }
    return [];
  }

  Future<RecyclingMaterial?> getMaterial(String id) async {
    if (indexedMaterialsCache.containsKey(id)) {
      return indexedMaterialsCache[id];
    }
    final snapshot = await dbRef.child(id).get();
    if (snapshot.exists) {
      final material = _fromFirebase(
        id,
        Map<String, dynamic>.from(snapshot.value as Map),
      );
      indexedMaterialsCache[id] = material;
      return material;
    }
    return null;
  }

  Future<void> registerMaterial(String nombre, num precioKilo) async {
    if (nombre.isEmpty) {
      throw Exception("El campo \"nombre\" debe no estar vacío");
    }
    if (precioKilo <= 0) {
      throw Exception("El campo \"precioKilo\" debe ser mayor a 0");
    }
    final newRef = dbRef.push();
    await newRef.set({"nombre": nombre, "precioKilo": precioKilo, "stock": 0});
    clearMaterialsCache();
  }

  Future<void> editMaterial(
    String id,
    String nombre,
    num precioKilo,
    num stock,
  ) async {
    await dbRef.child(id).update({
      "nombre": nombre,
      "precioKilo": precioKilo,
      "stock": stock,
    });
    clearMaterialsCache();
  }

  Future<void> incrementStock(String id, num cantidad) async {
    final materialSnapshot = await dbRef.child(id).get();
    if (!materialSnapshot.exists) {
      throw Exception("Material no encontrado");
    }
    final data = Map<String, dynamic>.from(materialSnapshot.value as Map);
    final stockActual = data["stock"] ?? 0;
    final nuevoStock = stockActual + cantidad;
    await dbRef.child(id).update({"stock": nuevoStock});
    clearMaterialsCache();
  }
}
