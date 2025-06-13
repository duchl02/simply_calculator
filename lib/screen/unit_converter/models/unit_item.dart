class UnitItem {
  final String name;
  final String shortName;
  final double conversionFactor;
  final bool isTemperature;

  const UnitItem({
    required this.name,
    required this.shortName,
    required this.conversionFactor,
    this.isTemperature = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnitItem &&
        other.name == name &&
        other.shortName == shortName &&
        other.conversionFactor == conversionFactor &&
        other.isTemperature == isTemperature;
  }

  @override
  int get hashCode =>
      name.hashCode ^
      shortName.hashCode ^
      conversionFactor.hashCode ^
      isTemperature.hashCode;
}
