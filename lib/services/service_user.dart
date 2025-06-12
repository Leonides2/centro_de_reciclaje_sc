import 'dart:convert';
import 'dart:math';
import 'package:centro_de_reciclaje_sc/services/service_email.dart';
import 'package:crypto/crypto.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_user.dart';
import 'package:firebase_database/firebase_database.dart';

class UserService {
  static final UserService instance = UserService();
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
      id: key,
      name1: data["name1"] ?? "",
      name2: data["name2"],
      lastName1: data["lastName1"] ?? "",
      lastName2: data["lastName2"],
      email: data["email"] ?? "",
      profilePictureUrl: data["profilePictureUrl"],
      passwordHash: data["passwordHash"],
      role: data["role"] ?? "Usuario",
    );
  }

  Future<List<User>> getUsers() async {
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
      }
      return users;
    }
    return [];
  }

  Future<void> registerUser({
    required String name1,
    String? lastName1,
    String? lastName2,
    required String email,
    required String password,
    String role = "Usuario",
  }) async {
    final passwordHash = hashPassword(password);
    final newRef = dbRef.push();
    await newRef.set({
      "id": newRef.key,
      "name1": name1.trim(),
      "lastName1": lastName1 != null ? lastName1.trim() : "",
      "lastName2": lastName2 != null ? lastName2.trim() : "",
      "email": email.trim(),
      "passwordHash": passwordHash,
      "role": role,
    });
  }

  Future<void> editUser({
    required String id,
    required String name1,
    String? lastName1,
    String? lastName2,
    required String email,
    String? password,
    String? profilePictureUrl,
    String role = "Usuario",
  }) async {
    String? passwordHash;
    if (password != null && password.isNotEmpty) {
      passwordHash = hashPassword(password);
    }
    final snapshot = await dbRef.orderByChild("email").equalTo(email).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final entry = data.entries.first;
      final userKey = entry.key;
      final userRef = dbRef.child(userKey);

      final updateData = {
        "name1": name1.trim(),
        "lastName1": lastName1 != null ? lastName1.trim() : "",
        "lastName2": lastName2 != null ? lastName2.trim() : "",
        "email": email.trim(),
        "profilePictureUrl": profilePictureUrl,
        "role": role,
      };
      if (passwordHash != null) {
        updateData["passwordHash"] = passwordHash;
      }
      await userRef.update(updateData);
    }
  }

  Future<void> deleteUser(String id) async {
    await dbRef.child(id).remove();
  }

  Future<void> ensureAdminUserExists() async {
    final users = await getUsers();
    if (users.isEmpty) {
      // Inserta un usuario administrador por defecto
      await registerUser(
        name1: "Administrador",
        lastName1: "Principal",
        lastName2: "",
        email: "admin@admin.com",
        password:
            "admin123", // Cambia esto por una contraseña segura en producción
        role: "Admin",
      );
    }
  }

  Future<User?> authenticate(String email, String password) async {
    final passwordHash = hashPassword(password);
    final snapshot = await dbRef.orderByChild("email").equalTo(email).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final entry = data.entries.first;
      final userData = Map<String, dynamic>.from(entry.value);
      if (userData["passwordHash"] == passwordHash) {
        return _fromFirebase(entry.key, userData);
      }
    }
    return null;
  }

  Future<void> resetPasswordAndSendEmail(String email) async {
    final snapshot = await dbRef.orderByChild("email").equalTo(email).get();
    if (!snapshot.exists) {
      throw Exception("No existe un usuario con ese correo.");
    }
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final entry = data.entries.first;
    final userKey = entry.key;
    final userData = Map<String, dynamic>.from(entry.value);

    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    String newPassword =
        List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
    final passwordHash = hashPassword(newPassword);

    await dbRef.child(userKey).update({"passwordHash": passwordHash});

    await EmailService.instance.sendPasswordChangeEmail(
      userData["email"],
      userData["name1"],
      newPassword,
    );
  }

  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final oldHash = hashPassword(oldPassword);
    final newHash = hashPassword(newPassword);

    final snapshot = await dbRef.orderByChild("email").equalTo(email).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final entry = data.entries.first;
      final userKey = entry.key;
      final userData = Map<String, dynamic>.from(entry.value);

      if (userData["passwordHash"] != oldHash) {
        throw Exception("La contraseña actual es incorrecta.");
      }

      await dbRef.child(userKey).update({"passwordHash": newHash});
      return;
    }
    throw Exception("Usuario no encontrado o contraseña incorrecta.");
  }
}
