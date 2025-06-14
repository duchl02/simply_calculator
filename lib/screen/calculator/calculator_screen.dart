import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/core/extensions/string_extension.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/core/managers/feature_tips_manager.dart';
import 'package:simply_calculator/data/hive/calc_local_data.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/domain/entities/calc_history_model.dart';
import 'package:simply_calculator/domain/repositories/app_repository.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/calculator/calc_history_service.dart';
import 'package:simply_calculator/screen/calculator/calculator_service.dart';
import 'package:simply_calculator/screen/calculator/widgets/calculator_display.dart';
import 'package:simply_calculator/screen/calculator/widgets/calculator_keypad.dart';
import 'package:simply_calculator/screen/calculator/widgets/empty_history_widget.dart';
import 'package:simply_calculator/screen/calculator/widgets/group_calc_history_widget.dart';
import 'package:simply_calculator/screen/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:simply_calculator/screen/widgets/button/app_filled_button.dart';
import 'package:simply_calculator/screen/widgets/drawer/app_drawer.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
  final _calculatorService = CalculatorService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routerInit = getIt<AppRepository>().getDefaultCalculator();
      if (routerInit != null && routerInit != CalculatorRoute.name) {
        context.router.push(NamedRoute(routerInit));
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          FeatureTipsManager.maybeShowRandomTip(context);
        }
      });
    });
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
      id: 0,
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
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: context.colorScheme.primary.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: () {
              context.pushRoute(const FeedbackRoute());
            },
            icon: const Icon(Icons.bug_report_rounded),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              final List<CalcHistoryModel> historyList =
                  await getIt<CalcLocalData>().getAll();
              if (context.mounted) {
                final groupedHistory = CalcHistoryService.groupHistoryByDate(
                  historyList,
                );
                await AppBottomSheet.show(
                  context: context,
                  initialChildSize: 0.6,
                  enableActions: historyList.isNotEmpty,
                  onRightButton: () async {
                    context.pop();
                    await context.router.push(const CalcHistoryRoute()).then((
                      value,
                    ) {
                      if (value != null && value is CalcHistoryModel) {
                        setState(() {
                          expression = value.expression;
                          result = value.result;
                          isEndCalculation = true;
                          _updateControllerFromExpression();
                          _calculateResult(fromEqual: false);
                        });
                      }
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      historyList.isEmpty
                          ? Column(
                            children: [
                              100.verticalSpace,
                              const EmptyHistoryWidget(),
                            ],
                          )
                          : GroupCalcHistoryWidget(
                            groupedHistory: groupedHistory,
                            onItemTap: (CalcHistoryModel item) {
                              setState(() {
                                expression = item.expression;
                                result = item.result;
                                isEndCalculation = true;
                                _updateControllerFromExpression();
                                _calculateResult(fromEqual: false);
                              });
                              context.pop();
                            },
                          ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        color: context.colorScheme.primary.withOpacity(0.1),
        child: Column(
          children: [
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
                onSelectionChanged: (selection) {},
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
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
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
                                    expression.substring(
                                      0,
                                      cursorPosition - 1,
                                    ) +
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
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 32,
                    ),
                    title: '⌫',
                    textStyle: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(
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
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                  child: CalculatorKeypad(
                    isSimple: isSimple,
                    onButtonPressed: onButtonPressed,
                    scaleTextSize: scaleTextSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onButtonPressed(String btnText) {
    setState(() {
      // Kiểm tra xem btnText có phải là toán tử không
      bool isOperator = ['+', '-', '×', '÷', '^', '%'].contains(btnText);
      bool isMathFunction = [
        'sin',
        'cos',
        'tan',
        'log',
        'ln',
        '√',
        '∛',
      ].contains(btnText);

      // Nếu đã có kết quả (isEndCalculation = true) và nhấn toán tử
      if (isEndCalculation && isOperator) {
        // Tiếp tục tính toán với kết quả trước đó + toán tử
        expression = result.formatAsFixed() + btnText;
        isEndCalculation = false;
        result = '';
        _updateControllerFromExpression();
        _expressionController.selection = TextSelection.collapsed(
          offset: expression.length,
        );
        return;
      }
      // Nếu đã có kết quả và nhấn hàm toán học
      else if (isEndCalculation && isMathFunction) {
        // Sử dụng kết quả làm đối số cho hàm toán học
        expression = btnText + '(' + result + ')';
        isEndCalculation = false;
        result = '';
        _updateControllerFromExpression();
        _expressionController.selection = TextSelection.collapsed(
          offset: expression.length,
        );
        return;
      }
      // Nếu đã có kết quả và nhấn bất kỳ phím nào khác (không phải toán tử hoặc hàm toán học)
      else if (isEndCalculation) {
        // Reset như cũ để bắt đầu phép tính mới
        expression = '';
        result = '';
        isEndCalculation = false;
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

      // Mở rộng xử lý cho các phím đặc biệt
      if (isEndCalculation) {
        switch (btnText) {
          case '(':
            // Bắt đầu một biểu thức mới với dấu ngoặc mở
            expression = '(';
            isEndCalculation = false;
            result = '';
            break;
          case ')':
            // Không làm gì vì không có ngoặc nào để đóng trong kết quả đơn lẻ
            return;
          case '.':
            // Tiếp tục với kết quả + dấu thập phân
            expression = result + '.';
            isEndCalculation = false;
            result = '';
            break;
          default:
            if (isOperator) {
              // Xử lý đã được thêm ở trên
              expression = result + btnText;
              isEndCalculation = false;
              result = '';
            } else if ('0123456789'.contains(btnText)) {
              // Bắt đầu một phép tính mới với số được nhấn
              expression = btnText;
              isEndCalculation = false;
              result = '';
            } else {
              // Các trường hợp khác, bắt đầu mới
              expression = '';
              result = '';
              isEndCalculation = false;
            }
        }

        _updateControllerFromExpression();
        _expressionController.selection = TextSelection.collapsed(
          offset: expression.length,
        );
        return;
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
      } catch (e) {
        // Xử lý lỗi
        isEndCalculation = false;
        result = '';
        expression += btnText;
        _expressionController.selection = TextSelection.collapsed(
          offset: expression.length,
        );
      }
    });
  }

  void _updateSelectionPosition() {}

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
