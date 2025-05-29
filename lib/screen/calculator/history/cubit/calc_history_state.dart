part of 'calc_history_cubit.dart';

class CalcHistoryState extends Equatable {
  const CalcHistoryState({
    this.history = const {},
    this.selectedGroup = const {},
  });

  final Map<String, List<CalcHistoryModel>> history;
  final Map<String, List<CalcHistoryModel>> selectedGroup;

  CalcHistoryState copyWith({Map<String, List<CalcHistoryModel>>? history}) {
    return CalcHistoryState(
      history: history ?? this.history,
      selectedGroup: selectedGroup,
    );
  }

  List<CalcHistoryModel> get historyItem =>
      history.values.expand((e) => e).toList();
  List<CalcHistoryModel> get selectedItem =>
      selectedGroup.values.expand((e) => e).toList();

  bool get isInSelectionMode => selectedGroup.isNotEmpty;

  int get selectedItemCount {
    int count = 0;
    for (final group in selectedGroup.values) {
      count += group.length;
    }
    return count;
  }

  @override
  List<Object?> get props => [history, selectedGroup];
}
