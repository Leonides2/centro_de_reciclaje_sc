String formatNum(num n) {
  return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
}
