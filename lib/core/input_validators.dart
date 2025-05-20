String? validateName(String? name) {
  if (name == null || name.isEmpty) {
    return "Campo requerido";
  }

  return null;
}

String? validatePrecioStock(String? n) {
  if (n == null || n.isEmpty) {
    return "Campo requerido";
  }

  if (num.tryParse(n) == null) {
    return "Número inválido";
  }

  return null;
}
