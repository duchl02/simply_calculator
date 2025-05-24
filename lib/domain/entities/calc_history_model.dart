import 'package:hive/hive.dart';
import 'package:simply_calculator/data/hive/hive_constants.dart';

part 'calc_history_model.g.dart';

@HiveType(typeId: HiveConstants.calcTypeId)
class CalcHistoryModel extends HiveObject {
  @HiveField(0)
  String expression;
  @HiveField(1)
  String result;
  @HiveField(2)
  String id;

  CalcHistoryModel({
    required this.expression,
    required this.result,
    required this.id,
  });
}
