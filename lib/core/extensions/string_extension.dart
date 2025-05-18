extension StringExtension on String {
  String formatAsFixed() {
    try {
      final double val = double.parse(this);
      return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
    } catch (e) {
      return this;
    }
  }
}
