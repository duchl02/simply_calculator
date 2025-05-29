import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:simply_calculator/data/hive/calc_local_data.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/domain/entities/calc_history_model.dart';
import 'package:simply_calculator/screen/calculator/calc_history_service.dart';

part 'calc_history_state.dart';

class CalcHistoryCubit extends Cubit<CalcHistoryState> {
  CalcHistoryCubit() : super(const CalcHistoryState());

  Future<void> loadHistory() async {
    final List<CalcHistoryModel> historyList =
        await getIt<CalcLocalData>().getAll();
    final Map<String, List<CalcHistoryModel>> groupedHistory =
        CalcHistoryService.groupHistoryByDate(historyList);
    emit(CalcHistoryState(history: groupedHistory));
  }

  Future<void> clearHistory() async {
    await getIt<CalcLocalData>().deleteBox();
    emit(const CalcHistoryState(history: {}));
  }

  Future<void> deleteMultipleHistoryItems() async {
    final List<CalcHistoryModel> selectedItems =
        state.selectedGroup.values.expand((e) => e).toList();
    for (final item in selectedItems) {
      await getIt<CalcLocalData>().deleteById(item);
    }
    final updatedHistory = Map<String, List<CalcHistoryModel>>.from(
      state.history,
    );
    updatedHistory.forEach((key, value) {
      updatedHistory[key] =
          value
              .where(
                (item) =>
                    !selectedItems.any((selected) => selected.id == item.id),
              )
              .toList();
    });
    emit(CalcHistoryState(history: updatedHistory));
  }

  void toggleSelectItem(CalcHistoryModel item) {
    // Tìm groupKey cho item
    String? groupKey;
    for (final entry in state.history.entries) {
      if (entry.value.any((historyItem) => historyItem.id == item.id)) {
        groupKey = entry.key;
        break;
      }
    }

    // Nếu không tìm thấy item trong bất kỳ nhóm nào, không thể tiếp tục
    if (groupKey == null) return;

    final updatedSelectedGroup = state.selectedGroup.map(
      (key, value) => MapEntry(key, List<CalcHistoryModel>.from(value)),
    );

    // Kiểm tra xem item đã được chọn chưa
    bool isItemSelected = false;
    for (final group in updatedSelectedGroup.values) {
      if (group.any((selectedItem) => selectedItem.id == item.id)) {
        isItemSelected = true;
        break;
      }
    }

    if (isItemSelected) {
      // Tìm và xóa item khỏi bất kỳ nhóm nào chứa nó
      for (final key in updatedSelectedGroup.keys.toList()) {
        updatedSelectedGroup[key] =
            updatedSelectedGroup[key]!
                .where((selectedItem) => selectedItem.id != item.id)
                .toList();

        // Xóa nhóm nếu trống
        if (updatedSelectedGroup[key]!.isEmpty) {
          updatedSelectedGroup.remove(key);
        }
      }
    } else {
      if (!updatedSelectedGroup.containsKey(groupKey)) {
        updatedSelectedGroup[groupKey] = [];
      }
      updatedSelectedGroup[groupKey]!.add(item);
    }

    emit(
      CalcHistoryState(
        history: state.history,
        selectedGroup: updatedSelectedGroup,
      ),
    );
  }

  // Kiểm tra trạng thái chọn của một item
  bool isItemSelected(CalcHistoryModel item) {
    for (final group in state.selectedGroup.values) {
      if (group.any((selectedItem) => selectedItem.id == item.id)) {
        return true;
      }
    }
    return false;
  }

  void cancelSelection() {
    emit(CalcHistoryState(history: state.history, selectedGroup: {}));
  }
}
