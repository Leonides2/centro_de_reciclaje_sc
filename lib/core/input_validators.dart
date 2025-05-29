import 'package:email_validator/email_validator.dart';

String? validateNotEmpty(String? name) {
  if (name == null || name.trim().isEmpty) {
    return "Campo requerido";
  }

  return null;
}

String? validatePrecioStock(String? n) {
  if (n == null || n.trim().isEmpty) {
    return "Campo requerido";
  }

  if (num.tryParse(n) == null) {
    return "Número inválido";
  }

  return null;
}

String? validateEmail(String? s) {
  if (s == null || s.trim().isEmpty) {
    return "Campo requerido";
  }

  if (!EmailValidator.validate(s)) {
    return "Dirección de correo inváilida";
  }

  return null;
}
