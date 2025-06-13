import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:simply_calculator/screen/unit_converter/models/unit_category.dart';
import 'package:simply_calculator/screen/unit_converter/models/unit_item.dart';

part 'unit_converter_state.dart';

class UnitConverterCubit extends Cubit<UnitConverterState> {
  UnitConverterCubit()
    : super(
        UnitConverterState(
          currentCategory: UnitCategory.length,
          fromUnit: UnitCategory.length.units.first,
          toUnit: UnitCategory.length.units[1],
          inputValue: '1',
        ),
      );

  void changeCategory(UnitCategory category) {
    emit(
      state.copyWith(
        currentCategory: category,
        fromUnit: category.units.first,
        toUnit:
            category.units.length > 1
                ? category.units[1]
                : category.units.first,
        inputValue: state.inputValue,
      ),
    );
  }

  void changeFromUnit(UnitItem unit) {
    emit(state.copyWith(fromUnit: unit));
  }

  void changeToUnit(UnitItem unit) {
    emit(state.copyWith(toUnit: unit));
  }

  void updateInputValue(String value) {
    emit(state.copyWith(inputValue: value));
  }

  void swapUnits() {
    emit(state.copyWith(fromUnit: state.toUnit, toUnit: state.fromUnit));
  }
}
