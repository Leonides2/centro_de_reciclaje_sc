import 'package:centro_de_reciclaje_sc/features/Models/model_user.dart';

class RoleService {
  static void assignRole(UserRole userRole, String newRole) {
    userRole.role = newRole;
  }

  static void updatePermissions(UserRole userRole, List<String> newPermissions) {
    userRole.permissions = newPermissions;
  }
}
