import 'package:freezed_annotation/freezed_annotation.dart';

part 'calc_history_model.freezed.dart';
part 'calc_history_model.g.dart';

@freezed
abstract class CalcHistoryModel with _$CalcHistoryModel {
  const factory CalcHistoryModel({
    required String expression,
    required String result,
    required DateTime timestamp,
  }) = _CalcHistoryModel;

  factory CalcHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$CalcHistoryModelFromJson(json);
}
