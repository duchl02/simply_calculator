import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:simply_calculator/data/data_source/base_hive_storage.dart';
import 'package:simply_calculator/data/hive/hive_constants.dart';
import 'package:simply_calculator/domain/entities/calc_history_model.dart';

@singleton
class CalcLocalData extends BaseHiveStorage<CalcHistoryModel> {
  CalcLocalData() : super(HiveConstants.calcHistoryBoxName) {
    Hive.registerAdapter(CalcHistoryModelAdapter());
  }

  Future<CalcHistoryModel?> getLast() async {
    final CalcHistoryModel? lastCalcHistory = await get('0');
    return lastCalcHistory;
  }

  Future<void> saveLast(CalcHistoryModel calcHistory) async {
    await putById(calcHistory);
  }

  @override
  Future<List<CalcHistoryModel>> getAll() async {
    final List<CalcHistoryModel> allCalcHistory = await super.getAll();
    final List<CalcHistoryModel> calcHistoryWithoutLast =
        allCalcHistory.where((element) => element.id != '0').toList();
    return calcHistoryWithoutLast;
  }
}
