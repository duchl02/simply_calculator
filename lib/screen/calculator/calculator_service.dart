import 'package:math_expressions/math_expressions.dart';
import 'package:simply_calculator/constants/calculator_constants.dart';
import 'package:simply_calculator/data/hive/calc_local_data.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/domain/entities/calc_history_model.dart';

class CalculatorService {
  final GrammarParser _parser = GrammarParser();

  // Tính toán biểu thức
  String calculate(
    String expression, {
    bool fromEqual = false,
    bool isDegreeMode = true,
  }) {
    if (expression.isEmpty) return '';

    try {
      final parsedExpression = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', CalculatorConstants.piValue)
          .replaceAll('e', CalculatorConstants.eValue)
          .replaceAll('√', 'sqrt')
          .replaceAll('∛', 'cbrt')
          .replaceAll('^', 'pow');

      final exp = _parser.parse(parsedExpression);
      final context = ContextModel();
      final eval = exp.evaluate(EvaluationType.REAL, context);
      if (fromEqual) {
        final CalcHistoryModel calcLastHistory = CalcHistoryModel(
          expression: expression,
          result: eval.toString(),
          id: DateTime.now().millisecondsSinceEpoch,
        );
        getIt<CalcLocalData>().putById(calcLastHistory);
      }
      return eval.toString();
    } catch (e) {
      return fromEqual ? 'ERROR' : '';
    }
  }

  String convertTrigonometricMode(String expression, bool isDegreeMode) {
    String newExpression = '';
    for (int i = 0; i < expression.length; i++) {
      final String char = expression[i];
      if (char == 's' &&
          i + 3 < expression.length &&
          expression.substring(i, i + 4) == 'sin(') {
        newExpression += isDegreeMode ? 'sin(' : 'sinRad(';
        i += 3;
      } else if (char == 'c' &&
          i + 3 < expression.length &&
          expression.substring(i, i + 4) == 'cos(') {
        newExpression += isDegreeMode ? 'cos(' : 'cosRad(';
        i += 3;
      } else if (char == 't' &&
          i + 3 < expression.length &&
          expression.substring(i, i + 4) == 'tan(') {
        newExpression += isDegreeMode ? 'tan(' : 'tanRad(';
        i += 3;
      } else {
        newExpression += char;
      }
    }
    return newExpression;
  }
}
