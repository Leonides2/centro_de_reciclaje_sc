

class User {
  User({
    this.id = '',
    this.name1 = '',
    this.name2,
    this.lastName1 = '',
    this.lastName2,
    this.email = '',
    this.profilePictureUrl,
    this.passwordHash, // Solo local
    this.role = "Usuario",
  });

  String id;
  String name1;
  String? name2;
  String lastName1;
  String? lastName2;
  String email;
  String? profilePictureUrl;
  String? passwordHash; // Solo en SQLite
  String role; // Puede ser "Super Admin", "Admin", "Usuario"

   User copyWith({
    String? id,
    String? name1,
    String? name2,
    String? lastName1,
    String? lastName2,
    String? email,
    String? profilePictureUrl,
    String? passwordHash,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name1: name1 ?? this.name1,
      name2: name2 ?? this.name2,
      lastName1: lastName1 ?? this.lastName1,
      lastName2: lastName2 ?? this.lastName2,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
    );
  }
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
