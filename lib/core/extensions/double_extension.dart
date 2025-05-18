extension DoubleExtension on double {
  String formatAsFixed() {
    return this % 1 == 0 ? toInt().toString() : toStringAsFixed(1);
  }
}
