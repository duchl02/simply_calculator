extension StringExtension on String {
  String formatAsFixed() {
    try {
      final double val = double.parse(this);
      if (val % 1 == 0) {
        return val.toInt().toString();
      }

      String result = val.toStringAsFixed(10);
      result = result.replaceFirst(RegExp(r'\.?0+$'), '');
      return result;
    } catch (e) {
      return this;
    }
  }
}
