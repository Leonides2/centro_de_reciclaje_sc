import 'dart:developer';

import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';

class MaterialService {
  static final MaterialService instance = MaterialService();
  final dbService = DatabaseService.instance;

  List<RecyclingMaterial>? materialsCache;
  Map<int, RecyclingMaterial> indexedMaterialsCache = {};

  final dbRef = FirebaseDatabase.instance.ref("materiales");

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

  // Nuevo: Convertir desde Firebase
  RecyclingMaterial _fromFirebase(String key, Map<dynamic, dynamic> data) {
    return RecyclingMaterial(
      id: int.tryParse(key) ?? 0,
      nombre: data["nombre"] ?? "",
      precioKilo: data["precioKilo"] ?? 0,
      stock: data["stock"] ?? 0,
    );
  }

  Future<List<RecyclingMaterial>> getMaterials() async {
    // 1. Intenta obtener de Firebase
    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final List<RecyclingMaterial> materials = [];
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        for (var entry in data.entries) {
          final mat = _fromFirebase(entry.key, Map<String, dynamic>.from(entry.value));
          materials.add(mat);
          // Sincroniza en SQLite
          await _saveToSQLite(mat);
        }
        materialsCache = materials;
        log("Materiales obtenidos de Firebase y sincronizados localmente");
        return materials;
      }
    } catch (e) {
      log("Error obteniendo de Firebase: $e");
    }

    // 2. Si falla, usa cache o SQLite
    if (materialsCache != null) {
      log("Returning from cache");
      return materialsCache!;
    }

    final db = await dbService.database;
    final materials = (await db.query("Material")).map(_toMaterial).toList();
    log("Materiales obtenidos de SQLite");
    materialsCache = materials;
    return materials;
  }

  // Guardar material en SQLite
  Future<void> _saveToSQLite(RecyclingMaterial material) async {
    final db = await dbService.database;
    await db.insert(
      "Material",
      {
        "Id": material.id,
        "Nombre": material.nombre,
        "PrecioKilo": material.precioKilo,
        "Stock": material.stock,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

    // 1. Registrar en Firebase
    final newRef = dbRef.push();
    final material = RecyclingMaterial(
      id: int.tryParse(newRef.key ?? '0') ?? 0,
      nombre: nombre,
      precioKilo: precioKilo,
      stock: 0,
    );
    await newRef.set({
      "nombre": nombre,
      "precioKilo": precioKilo,
      "stock": 0,
    });

    // 2. Registrar en SQLite
    await _saveToSQLite(material);

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
    // 1. Editar en Firebase
    final matRef = dbRef.child(id.toString());
    await matRef.set({
      "nombre": nombre,
      "precioKilo": precioKilo,
      "stock": stock,
    });

    // 2. Editar en SQLite
    final db = await dbService.database;
    await db.update(
      "Material",
      {"Nombre": nombre, "PrecioKilo": precioKilo, "Stock": stock},
      where: "Id = ?",
      whereArgs: [id],
    );
  }
}