import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:simply_calculator/data/hive/calc_local_data.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/domain/entities/calc_history_model.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/calculator/calculator_service.dart';
import 'package:simply_calculator/screen/calculator/widgets/calculator_display.dart';
import 'package:simply_calculator/screen/calculator/widgets/calculator_keypad.dart';
import 'package:simply_calculator/screen/widgets/button/app_filled_button.dart';
import 'dart:math' as math;

@RoutePage()
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool isSimple = true;
  String expression = '';
  bool isDegreeMode = true;
  double get scaleTextSize => isSimple ? 1.5 : 1.0;
  bool isEndCalculation = false;
  late TextEditingController _expressionController;
  String result = '';
  String resultCur = '';
  TextSelection _lastKnownSelection = const TextSelection.collapsed(offset: 0);
  final _calculatorService = CalculatorService();

  @override
  void initState() {
    super.initState();
    _expressionController = TextEditingController(text: expression);
    _expressionController.addListener(_updateExpressionFromController);
    init();
  }

  Future<void> init() async {
    final lastHistory = await getIt<CalcLocalData>().getLast();
    _expressionController.text = lastHistory?.expression ?? '';
    expression = _expressionController.text;
    result = lastHistory?.result ?? '';
    resultCur = result;
    isEndCalculation = result.isNotEmpty;
    _updateControllerFromExpression();
  }

  @override
  void dispose() {
    _expressionController.removeListener(_updateExpressionFromController);
    _expressionController.dispose();
    super.dispose();
  }

  void _updateExpressionFromController() {
    if (_expressionController.text != expression) {
      setState(() {
        expression = _expressionController.text;
      });
    }
    _calculateResult(fromEqual: false);
    final CalcHistoryModel calcLastHistory = CalcHistoryModel(
      expression: expression,
      result: result,
      id: '0',
    );
    getIt<CalcLocalData>().saveLast(calcLastHistory);
  }

  void _updateControllerFromExpression() {
    if (_expressionController.text != expression) {
      _expressionController.text = expression;
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateControllerFromExpression();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        title: Text(t.basic_calculator),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              final List<CalcHistoryModel> historyList =
                  await getIt<CalcLocalData>().getAll();
              await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView.builder(
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        final history = historyList[index];
                        return ListTile(
                          title: Text(history.expression),
                          subtitle: Text(history.result),
                          onTap: () {
                            setState(() {
                              expression = history.expression;
                              result = history.result;
                              isEndCalculation = true;
                              _expressionController.text = expression;
                              _lastKnownSelection =
                                  const TextSelection.collapsed(offset: 0);
                            });
                            AutoRouter.of(context).pop();
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calculator Display
          Expanded(
            flex: isSimple ? 4 : 3,
            child: CalculatorDisplay(
              expressionController: _expressionController,
              expression: expression,
              result: result,
              resultCur: resultCur,
              isEndCalculation: isEndCalculation,
              onExpressionChanged: (value) {
                setState(() {
                  expression = value;
                  _calculateResult(fromEqual: false);
                  _updateSelectionPosition();
                });
              },
              onTap: () {
                if (isEndCalculation) {
                  setState(() {
                    isEndCalculation = false;
                    result = '';
                  });
                }
                _updateSelectionPosition();
              },
              onSelectionChanged: (selection) {
                _lastKnownSelection = selection;
              },
            ),
          ),

          // Mode controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Changing calculator mode
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isSimple = !isSimple;
                    });
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      isSimple ? Icons.functions : Icons.calculate,
                      key: ValueKey<bool>(isSimple),
                      size: 24,
                    ),
                  ),
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isSimple ? t.scientific : t.basic,
                      key: ValueKey<bool>(isSimple),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Degree/Radian toggle
                if (!isSimple)
                  ElevatedButton(
                    onPressed: _toggleDegreeRadianMode,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isDegreeMode ? 'Deg' : 'Rad',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                const Spacer(),

                // Backspace button
                AppFilledButton(
                  onTap: () {
                    setState(() {
                      // Reset nếu đang ở trạng thái kết thúc phép tính
                      if (isEndCalculation) {
                        isEndCalculation = false;
                        result = '';
                      }

                      if (expression.isNotEmpty) {
                        try {
                          // Lấy vị trí con trỏ hiện tại
                          final selection = _expressionController.selection;

                          // Trường hợp 1: Có vùng văn bản được chọn
                          if (selection.isValid &&
                              selection.start != selection.end) {
                            final start = selection.start;
                            final end = selection.end;

                            // Xóa phần văn bản được chọn
                            expression =
                                expression.substring(0, start) +
                                expression.substring(end);

                            // Cập nhật controller trước
                            _expressionController.text = expression;

                            // Đặt lại vị trí con trỏ
                            _expressionController.selection =
                                TextSelection.collapsed(offset: start);
                          }
                          // Trường hợp 2: Không có vùng văn bản được chọn, xóa 1 ký tự trước con trỏ
                          else {
                            final cursorPosition =
                                selection.isValid
                                    ? selection.start
                                    : expression.length;

                            if (cursorPosition > 0) {
                              // Xóa 1 ký tự trước con trỏ
                              expression =
                                  expression.substring(0, cursorPosition - 1) +
                                  expression.substring(cursorPosition);

                              // Cập nhật controller trước
                              _expressionController.text = expression;

                              // Đặt lại vị trí con trỏ
                              _expressionController
                                  .selection = TextSelection.collapsed(
                                offset: cursorPosition - 1,
                              );
                            }
                          }

                          // Lưu vị trí con trỏ mới
                          _lastKnownSelection = _expressionController.selection;

                          // Tính toán kết quả mới
                          _calculateResult(fromEqual: false);
                        } catch (e) {
                          // Nếu có lỗi, xóa ký tự cuối cùng một cách đơn giản
                          if (expression.isNotEmpty) {
                            expression = expression.substring(
                              0,
                              expression.length - 1,
                            );
                            _expressionController.text = expression;
                            _expressionController
                                .selection = TextSelection.collapsed(
                              offset: expression.length,
                            );
                            _calculateResult(fromEqual: false);
                          }
                        }
                      }
                    });
                  },
                  onLongPress: () {
                    setState(() {
                      result = '';
                      expression = '';
                      resultCur = '';
                      _expressionController.clear();
                      _lastKnownSelection = const TextSelection.collapsed(
                        offset: 0,
                      );
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 32,
                  ),
                  title: '⌫',
                  textStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                    height: 0,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Calculator Keypad
          Expanded(
            flex: isSimple ? 6 : 7,
            child: Padding(
              padding: const EdgeInsets.all(8.0).copyWith(top: 0),
              child: CalculatorKeypad(
                isSimple: isSimple,
                onButtonPressed: onButtonPressed,
                scaleTextSize: scaleTextSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onButtonPressed(String btnText) {
    setState(() {
      if (isEndCalculation) {
        expression = '';
        result = '';
        isEndCalculation = false;
        _lastKnownSelection = const TextSelection.collapsed(offset: 0);
      }

      // Kiểm tra và đảm bảo vị trí con trỏ không vượt quá độ dài chuỗi
      final currentSelection = _expressionController.selection;
      final selectionStart = math.min(
        (currentSelection.start >= 0
            ? currentSelection.start
            : expression.length),
        expression.length,
      );
      final selectionEnd = math.min(
        (currentSelection.end >= 0 ? currentSelection.end : expression.length),
        expression.length,
      );

      String newExpression = '';
      int newCursorPosition = selectionStart;

      switch (btnText) {
        case 'C':
          newExpression = '';
          result = '';
          newCursorPosition = 0;
          break;
        case '=':
          _calculateResult(fromEqual: true);
          return; // Không cần cập nhật vị trí con trỏ
        case '(':
          // Kiểm tra cần thêm dấu nhân không
          if (selectionStart > 0 &&
              !'+-×÷('.contains(expression[selectionStart - 1])) {
            // Chèn '×' tại vị trí con trỏ
            newExpression =
                expression.substring(0, selectionStart) +
                '×(' +
                expression.substring(selectionEnd);
            newCursorPosition = selectionStart + 2; // Sau '×('
          } else {
            // Chèn '(' tại vị trí con trỏ
            newExpression =
                expression.substring(0, selectionStart) +
                '(' +
                expression.substring(selectionEnd);
            newCursorPosition = selectionStart + 1; // Sau '('
          }
          break;
        case ')':
          // Đếm ngoặc mở và ngoặc đóng trong biểu thức
          int openCount = 0;
          int closeCount = 0;

          for (int i = 0; i < expression.length; i++) {
            if (expression[i] == '(') openCount++;
            if (expression[i] == ')') closeCount++;
          }

          if (openCount > closeCount) {
            // Chèn ')' tại vị trí con trỏ
            newExpression =
                expression.substring(0, selectionStart) +
                ')' +
                expression.substring(selectionEnd);
            newCursorPosition = selectionStart + 1; // Sau ')'
          } else {
            // Không đủ ngoặc mở, giữ nguyên biểu thức
            newExpression = expression;
            newCursorPosition = selectionStart;
          }
          break;
        case 'sin':
        case 'cos':
        case 'tan':
        case 'log':
        case 'ln':
        case '√':
        case '∛':
          // Chèn hàm tại vị trí con trỏ
          newExpression =
              expression.substring(0, selectionStart) +
              '$btnText(' +
              expression.substring(selectionEnd);
          newCursorPosition =
              selectionStart + btnText.length + 1; // Sau 'func('
          break;
        case '!':
        case 'φ':
        case '.':
          // Xử lý như các trường hợp đặc biệt khác
          if (btnText == 'φ') {
            newExpression =
                expression.substring(0, selectionStart) +
                '1.6180339887' +
                expression.substring(selectionEnd);
            newCursorPosition = selectionStart + 11; // Sau số phi
          } else if (btnText == '.') {
            // Kiểm tra xem đã có dấu chấm trong số hiện tại chưa
            bool hasDecimalInCurrentNumber = false;
            // Kiểm tra từ vị trí hiện tại trở về trước
            for (int i = selectionStart - 1; i >= 0; i--) {
              if (!RegExp(r'[0-9]').hasMatch(expression[i])) {
                break; // Không phải số, dừng
              }
              if (expression[i] == '.') {
                hasDecimalInCurrentNumber = true;
                break;
              }
            }
            // Kiểm tra từ vị trí hiện tại trở về sau
            for (int i = selectionStart; i < expression.length; i++) {
              if (!RegExp(r'[0-9]').hasMatch(expression[i])) {
                break; // Không phải số, dừng
              }
              if (expression[i] == '.') {
                hasDecimalInCurrentNumber = true;
                break;
              }
            }

            if (!hasDecimalInCurrentNumber) {
              newExpression =
                  expression.substring(0, selectionStart) +
                  '.' +
                  expression.substring(selectionEnd);
              newCursorPosition = selectionStart + 1; // Sau '.'
            } else {
              newExpression = expression;
              newCursorPosition = selectionStart;
            }
          } else {
            newExpression =
                expression.substring(0, selectionStart) +
                btnText +
                expression.substring(selectionEnd);
            newCursorPosition = selectionStart + btnText.length;
          }
          break;
        default:
          try {
            // Chèn ký tự thường tại vị trí con trỏ
            newExpression =
                expression.substring(0, selectionStart) +
                btnText +
                expression.substring(selectionEnd);
            newCursorPosition = selectionStart + btnText.length;
          } catch (e) {
            // Nếu có lỗi xảy ra, giữ nguyên biểu thức
            newExpression = expression;
            newCursorPosition = selectionStart;
          }
      }

      try {
        // Cập nhật biểu thức và vị trí con trỏ
        expression = newExpression;
        _updateControllerFromExpression();

        // Kiểm tra để đảm bảo newCursorPosition không vượt quá độ dài chuỗi
        newCursorPosition = math.min(newCursorPosition, expression.length);

        _expressionController.selection = TextSelection.collapsed(
          offset: newCursorPosition,
        );
        _lastKnownSelection = _expressionController.selection;
      } catch (e) {
        // Xử lý lỗi
        isEndCalculation = false;
        result = '';
        expression += btnText;
        _expressionController.selection = TextSelection.collapsed(
          offset: expression.length,
        );
        _lastKnownSelection = _expressionController.selection;
      }
    });
  }

  void _updateSelectionPosition() {
    _lastKnownSelection = _expressionController.selection;
  }

  void _calculateResult({required bool fromEqual}) {
    if (fromEqual && isEndCalculation) {
      return;
    }

    if (fromEqual) {
      isEndCalculation = true;
    }

    final resultString = _calculatorService.calculate(
      expression,
      fromEqual: fromEqual,
      isDegreeMode: isDegreeMode,
    );

    setState(() {
      if (fromEqual) {
        result = resultString;
      } else {
        resultCur = resultString;
      }
    });
  }

  void _toggleDegreeRadianMode() {
    setState(() {
      isDegreeMode = !isDegreeMode;
      expression = _calculatorService.convertTrigonometricMode(
        expression,
        isDegreeMode,
      );
    });
  }
}
