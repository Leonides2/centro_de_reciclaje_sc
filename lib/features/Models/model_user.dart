

class User {
  User({
    this.id = 0,
    this.name1 = '',
    this.name2,
    this.lastName1 = '',
    this.lastName2,
    this.email = '',
    this.profilePictureUrl,
    this.passwordHash, // Solo local
    this.role = "Usuario",
  });

  int id;
  String name1;
  String? name2;
  String lastName1;
  String? lastName2;
  String email;
  String? profilePictureUrl;
  String? passwordHash; // Solo en SQLite
  String role; // Puede ser "Super Admin", "Admin", "Usuario"
}

class UserRole {
  UserRole({
    required this.userId,
    this.role = "Usuario",
    this.permissions = const [],
  });

  int userId; // Referencia al usuario
  String role; // Puede ser "Super Admin", "Admin", "Usuario"
  List<String> permissions; // Lista de permisos, como "crear_reportes"
}
