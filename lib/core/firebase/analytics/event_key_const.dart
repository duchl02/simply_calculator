part of 'analytics_util.dart';

class EventKeyConst {
  // History screen events
  static const String historyItemToggled = 'history_item_toggled';
  static const String historyItemUsed = 'history_item_used';
  static const String historySelectionModeEntered = 'history_selection_mode_entered';
  static const String historySelectionModeExited = 'history_selection_mode_exited';
  static const String historyItemsDeleted = 'history_items_deleted';
  static const String historyClearDialogShown = 'history_clear_dialog_shown';
  static const String historyCleared = 'history_cleared';
  static const String historyClearCanceled = 'history_clear_canceled';
  // Calculator button events
  static const String numberButtonPressed = 'number_button_pressed';
  static const String operatorButtonPressed = 'operator_button_pressed';
  static const String equalButtonPressed = 'equal_button_pressed';
  static const String clearButtonPressed = 'clear_button_pressed';
  static const String backspaceButtonPressed = 'backspace_button_pressed';
  static const String calculatorModeToggled = 'calculator_mode_toggled';
  static const String degreeRadianToggled = 'degree_radian_toggled';
  static const String historyButtonPressed = 'history_button_pressed';
  static const String functionButtonPressed = 'function_button_pressed';
  static const String parenthesisButtonPressed = 'parenthesis_button_pressed';
  static const String decimalPointPressed = 'decimal_point_pressed';

  // Unit Converter button events
  static const String unitCategorySelected = 'unit_category_selected';
  static const String unitFromChanged = 'unit_from_changed';
  static const String unitToChanged = 'unit_to_changed';
  static const String unitSwapButtonPressed = 'unit_swap_button_pressed';
  static const String unitInputCleared = 'unit_input_cleared';
  static const String unitResultCopied = 'unit_result_copied';
  static const String unitCommonConversionSelected = 'unit_common_conversion_selected';
}
