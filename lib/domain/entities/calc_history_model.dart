import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:simply_calculator/data/hive/hive_constants.dart';

part 'calc_history_model.g.dart';

@HiveType(typeId: HiveConstants.calcTypeId)
class CalcHistoryModel extends Equatable {
  @HiveField(0)
  final String expression;

  @HiveField(1)
  final String result;

  @HiveField(2)
  final int id;

  const CalcHistoryModel({
    required this.expression,
    required this.result,
    required this.id,
  });

  @override
  List<Object?> get props => [expression, result, id];
}
