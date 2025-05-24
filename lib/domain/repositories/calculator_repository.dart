import 'package:simply_calculator/domain/entities/calc_history_model.dart';

abstract class CalculatorRepository {
  Future<void> addHistory(CalcHistoryModel history);

  Future<List<CalcHistoryModel>> getHistory();

  Future<void> deleteHistory(String id);

  Future<void> clearHistory();

}
