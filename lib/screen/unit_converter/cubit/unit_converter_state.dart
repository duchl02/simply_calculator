part of 'unit_converter_cubit.dart';

class UnitConverterState extends Equatable {
  final UnitCategory currentCategory;
  final UnitItem fromUnit;
  final UnitItem toUnit;
  final String inputValue;

  const UnitConverterState({
    required this.currentCategory,
    required this.fromUnit,
    required this.toUnit,
    required this.inputValue,
  });

  UnitConverterState copyWith({
    UnitCategory? currentCategory,
    UnitItem? fromUnit,
    UnitItem? toUnit,
    String? inputValue,
  }) {
    return UnitConverterState(
      currentCategory: currentCategory ?? this.currentCategory,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      inputValue: inputValue ?? this.inputValue,
    );
  }

  @override
  List<Object> get props => [currentCategory, fromUnit, toUnit, inputValue];
}
