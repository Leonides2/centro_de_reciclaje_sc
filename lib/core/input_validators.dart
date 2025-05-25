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
