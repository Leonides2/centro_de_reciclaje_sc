import 'dart:convert';
import 'dart:math';
import 'package:centro_de_reciclaje_sc/services/service_email.dart';
import 'package:crypto/crypto.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_user.dart';
import 'package:centro_de_reciclaje_sc/services/service_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';

class UserService {
  static final UserService instance = UserService();
  final dbService = DatabaseService.instance;
  final dbRef = FirebaseDatabase.instance.ref("usuarios");

  List<User>? usersCache;

  void clearUsersCache() {
    usersCache = null;
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  User _fromFirebase(String key, Map<dynamic, dynamic> data) {
    return User(
      id: int.tryParse(key) ?? 0,
      name1: data["name1"] ?? "",
      name2: data["name2"],
      lastName1: data["lastName1"] ?? "",
      lastName2: data["lastName2"],
      email: data["email"] ?? "",
      profilePictureUrl: data["profilePictureUrl"],
      passwordHash: data["passwordHash"], // Ahora sí se sincroniza el hash
      role: data["role"] ?? "Usuario", // Asignar el rol
    );
  }

  User _fromSqlite(Map<String, Object?> e) => User(
    id: e["Id"] as int,
    name1: e["Nombre"] as String,
    lastName1: e["LastName1"] as String? ?? "",
    lastName2: e["LastName2"] as String?,
    email: e["Email"] as String,
    passwordHash: e["Password"] as String?,
    profilePictureUrl: e["ProfilePictureUrl"] as String?,
    role: e["Role"] as String? ?? "Usuario", // Asignar el rol
  );

  Future<List<User>> getUsers() async {
    // 1. Intenta obtener de Firebase
    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final List<User> users = [];
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        for (var entry in data.entries) {
          final user = _fromFirebase(
            entry.key,
            Map<String, dynamic>.from(entry.value),
          );
          users.add(user);
          await _saveToSQLite(user, passwordHash: user.passwordHash);
        }
        usersCache = users;
        return users;
      }
    } catch (e) {}

    // 2. Si falla, usa cache o SQLite
    if (usersCache != null) return usersCache!;

    final db = await dbService.database;
    final users = (await db.query("Usuario")).map(_fromSqlite).toList();
    usersCache = users;
    return users;
  }

  // Guardar usuario en SQLite (con hash)
  Future<void> _saveToSQLite(User user, {String? passwordHash}) async {
    final db = await dbService.database;
    await db.insert("Usuario", {
      "Id": user.id,
      "Nombre": user.name1,
      "LastName1": user.lastName1,
      "LastName2": user.lastName2,
      "Email": user.email,
      "Password": passwordHash ?? user.passwordHash,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> registerUser({
    required String name1,
    String? lastName1,
    String? lastName2,
    required String email,
    required String password,
    String role = "Usuario", // Por defecto, el rol es "Usuario"
  }) async {
    // 1. Registrar en Firebase (con hash)
    final passwordHash = hashPassword(password);
    final newRef = dbRef.push();
    final user = User(
      id: int.tryParse(newRef.key ?? '0') ?? 0,
      name1: name1,
      lastName1: lastName1 ?? '',
      lastName2: lastName2,
      email: email,
      passwordHash: passwordHash,
      role: role, // Asignar el rol
    );
    await newRef.set({
      "name1": name1,
      "lastName1": lastName1,
      "lastName2": lastName2,
      "email": email,
      "passwordHash": passwordHash, // Subimos el hash
      "role": role, // Guardar el rol en Firebase
    });

    // 2. Registrar en SQLite (con hash)
    await _saveToSQLite(user, passwordHash: passwordHash);

    clearUsersCache();
  }

  Future<void> editUser({
    required int id,
    required String name1,
    String? lastName1,
    String? lastName2,
    required String email,
    String? password, // Si es null, no se cambia la contraseña
    String? profilePictureUrl,
    String role = "Usuario", // Por defecto, el rol es "Usuario"
  }) async {
    // Si hay nueva contraseña, hashearla
    String? passwordHash;
    if (password != null && password.isNotEmpty) {
      passwordHash = hashPassword(password);
    }

    // 1. Editar en Firebase
    // Busca el usuario por email para obtener la key de Firebase
    final snapshot = await dbRef.orderByChild("email").equalTo(email).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final entry = data.entries.first;
      final userKey = entry.key;
      final userRef = dbRef.child(userKey);

      final updateData = {
        "name1": name1,
        "lastName1": lastName1,
        "lastName2": lastName2,
        "email": email,
        "profilePictureUrl": profilePictureUrl,
        "role": role,
      };
      if (passwordHash != null) {
        updateData["passwordHash"] = passwordHash;
      }
      await userRef.update(updateData);
    }

    // 2. Editar en SQLite
    final db = await dbService.database;
    final updateSqlite = {
      "Nombre": name1,
      "LastName1": lastName1,
      "LastName2": lastName2,
      "Email": email,
      "ProfilePictureUrl": profilePictureUrl,
      "Role": role,
    };
    if (passwordHash != null) {
      updateSqlite["Password"] = passwordHash;
    }
    await db.update("Usuario", updateSqlite, where: "Id = ?", whereArgs: [id]);

    clearUsersCache();
  }

  Future<void> deleteUser(int id) async {
    final db = await dbService.database;
    await db.delete("Usuario", where: "Id = ?", whereArgs: [id]);
    await dbRef.child(id.toString()).remove();
    clearUsersCache();
  }

  /// Autenticación universal: busca primero en Firebase, si falla usa SQLite.
  Future<User?> authenticate(String email, String password) async {
    final passwordHash = hashPassword(password);

    // 1. Busca el usuario en Firebase por email
    try {
      final snapshot = await dbRef.orderByChild("email").equalTo(email).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final entry = data.entries.first;
        final userData = Map<String, dynamic>.from(entry.value);
        if (userData["passwordHash"] == passwordHash) {
          // Login exitoso, sincroniza localmente
          final user = _fromFirebase(entry.key, userData);
          await _saveToSQLite(user, passwordHash: passwordHash);
          return user;
        }
      }
    } catch (e) {}

    // 2. Si falla, intenta autenticación local
    final db = await dbService.database;
    final users = await db.query(
      "Usuario",
      where: "Email = ? AND Password = ?",
      whereArgs: [email, passwordHash],
    );
    if (users.isNotEmpty) {
      return _fromSqlite(users.first);
    }
    return null;
  }

  Future<void> resetPasswordAndSendEmail(String email) async {
    // 1. Buscar usuario por email en Firebase
    final snapshot = await dbRef.orderByChild("email").equalTo(email).get();
    if (!snapshot.exists) {
      throw Exception("No existe un usuario con ese correo.");
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final entry = data.entries.first;
    final userKey = entry.key;
    final userData = Map<String, dynamic>.from(entry.value);

    // 2. Generar contraseña aleatoria de 8 caracteres
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    String newPassword =
        List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();

    // 3. Hashear la contraseña
    final passwordHash = hashPassword(newPassword);

    // 4. Actualizar en Firebase
    await dbRef.child(userKey).update({"passwordHash": passwordHash});

    // 5. Actualizar en SQLite (si existe localmente)
    final db = await dbService.database;
    await db.update(
      "Usuario",
      {"Password": passwordHash},
      where: "Email = ?",
      whereArgs: [email],
    );

    // 6. Enviar correo con la nueva contraseña
    final text = '''
    <h2>Recuperación de contraseña</h2>
    <p>Hola ${userData["name1"] ?? ""},</p>
    <p>Tu nueva contraseña es: <b>$newPassword</b></p>
    <p>Por favor, cámbiala después de iniciar sesión.</p>
    <p>Centro de Reciclaje de Santa Cruz</p>
    ''';

    final title = "Recuperación de contraseña - Centro de Reciclaje SC";
    await EmailService.instance.sendNewPassword(email, text, title);
  }

  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final oldHash = hashPassword(oldPassword);
    final newHash = hashPassword(newPassword);

    // 1. Busca el usuario en Firebase por email
    final snapshot = await dbRef.orderByChild("email").equalTo(email).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final entry = data.entries.first;
      final userKey = entry.key;
      final userData = Map<String, dynamic>.from(entry.value);

      // Verifica la contraseña antigua
      if (userData["passwordHash"] != oldHash) {
        throw Exception("La contraseña actual es incorrecta.");
      }

      // Actualiza en Firebase
      await dbRef.child(userKey).update({"passwordHash": newHash});

      // Actualiza en SQLite si existe localmente
      final db = await dbService.database;
      await db.update(
        "Usuario",
        {"Password": newHash},
        where: "Email = ?",
        whereArgs: [email],
      );

      clearUsersCache();
      return;
    }

    // 2. Si no está en Firebase, intenta en SQLite
    final db = await dbService.database;
    final users = await db.query(
      "Usuario",
      where: "Email = ? AND Password = ?",
      whereArgs: [email, oldHash],
    );
    if (users.isEmpty) {
      throw Exception("Usuario no encontrado o contraseña incorrecta.");
    }

    // Actualiza en SQLite
    await db.update(
      "Usuario",
      {"Password": newHash},
      where: "Email = ?",
      whereArgs: [email],
    );

    clearUsersCache();
  }
}
