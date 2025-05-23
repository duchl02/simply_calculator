import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/core/extensions/string_extension.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/widgets/button/app_filled_button.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSimple = true;
  String expression = '';
  bool isDegreeMode = true;
  double get scaleTextSize => isSimple ? 1.5 : 1.0;
  final _parser = GrammarParser();
  bool isEndCalculation = false;
  late TextEditingController _expressionController;
  String result = '';
  String resultCur = '';
  TextSelection _lastKnownSelection = const TextSelection.collapsed(offset: 0);

  @override
  void initState() {
    super.initState();
    _expressionController = TextEditingController(text: expression);
    _expressionController.addListener(_updateExpressionFromController);
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
    calculator();
  }

  void _updateControllerFromExpression() {
    if (_expressionController.text != expression) {
      _expressionController.text = expression;
    }
  }

  final List<String> allButtons = [
    'φ',
    'e',
    'ln',
    'log',
    'sin',
    'cos',
    'tan',
    'π',
    '!',
    '∛',
    '√',
    '^',
    '(',
    ')', // Thay đổi từ '( )' thành ')'
    '%',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    'C',
    '0',
    '.',
    '=',
  ];

  final List<String> basicButtons = [
    '(',
    ')', // Thay đổi từ '( )' thành ')'
    '%',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    'C',
    '0',
    '.',
    '=',
  ];
  @override
  Widget build(BuildContext context) {
    _updateControllerFromExpression();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        title: Text(getIt<AppCubit>().state.theme.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: isSimple ? 4 : 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 1,
                    child: Stack(
                      children: [
                        // Layer 1: Actual editable TextField (transparent text)
                        TextField(
                          controller: _expressionController,
                          textAlign: TextAlign.end,
                          expands: true,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            filled: false,
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize:
                                  isEndCalculation
                                      ? 40
                                      : expression.length > 10
                                      ? 40
                                      : 70,
                              color: context.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                          style: context.textTheme.displayMedium?.copyWith(
                            fontSize:
                                isEndCalculation
                                    ? 40
                                    : expression.length > 10
                                    ? 40
                                    : 70,
                            height: 1,
                            color: Colors.transparent, // Make text invisible
                          ),
                          keyboardType: TextInputType.none,
                          enableInteractiveSelection: true,
                          onTap: () {
                            if (isEndCalculation == true) {
                              setState(() {
                                isEndCalculation = false;
                                result = '';
                              });
                            }
                            _updateSelectionPosition();
                          },
                          onChanged: (value) {
                            setState(() {
                              expression = value;
                              calculator();
                              _updateSelectionPosition();
                            });
                          },
                        ),

                        // Layer 2: Colored brackets display (non-editable)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: _buildExpressionWithColoredBrackets(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    (isEndCalculation ? result : resultCur).isEmpty
                        ? ''
                        : '= ${(isEndCalculation ? result : resultCur).trim().formatAsFixed()}',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontSize:
                          isEndCalculation
                              ? expression.length > 10
                                  ? 40
                                  : 70
                              : 40,
                      fontWeight: FontWeight.normal,
                      color: context.colorScheme.onSurface.withOpacity(
                        isEndCalculation ? 1 : 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
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
                      style: context.textTheme.titleMedium?.copyWith(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                isSimple
                    ? const SizedBox()
                    : ElevatedButton(
                      onPressed: () {
                        onTapDegRad();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isDegreeMode ? 'Deg' : 'Rad',
                        style: context.textTheme.titleMedium?.copyWith(),
                      ),
                    ),
                Spacer(),
                AppFilledButton(
                  onTap: () {
                    // int randomNumber = Random().nextInt(52);
                    // getIt<AppCubit>().setTheme(FlexScheme.values[randomNumber]);
                    // getIt<AppCubit>().setDarkMode(
                    //   !getIt<AppCubit>().state.isDarkMode,
                    // );
                    // getIt<AppCubit>().setFontFamily(
                    //   AppFontFamily
                    //       .values[Random().nextInt(AppFontFamily.values.length)]
                    //       .id,
                    // );

                    {
                      if (isEndCalculation) {
                        isEndCalculation = false;
                        result = '';
                      }
                      expression =
                          expression.length > 1
                              ? expression.substring(0, expression.length - 1)
                              : '';
                      setState(() {});
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      result = '';
                      expression = '';
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 32,
                  ),
                  title: '⌫',
                  textStyle: context.textTheme.displaySmall?.copyWith(
                    height: 0,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: isSimple ? 6 : 7,
            child: Padding(
              padding: const EdgeInsets.all(8.0).copyWith(top: 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buttons = isSimple ? basicButtons : allButtons;

                  final int crossAxisCount = 4;
                  final int rowCount = (buttons.length / crossAxisCount).ceil();

                  final double spacing = 8.0;
                  final double totalSpacingY = spacing * (rowCount - 1);
                  final double totalSpacingX = spacing * (crossAxisCount - 1);

                  final double itemHeight =
                      (constraints.maxHeight - totalSpacingY) / rowCount;
                  final double itemWidth =
                      (constraints.maxWidth - totalSpacingX) / crossAxisCount;
                  final double aspectRatio = itemWidth / itemHeight;

                  return GridView.builder(
                    itemCount: buttons.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final btnText = buttons[index];

                      return AllButton(
                        btnText: btnText,
                        onAction: onButtonPressed,
                        scaleTextSize: scaleTextSize,
                      );
                    },
                  );
                },
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

      // Lấy vị trí con trỏ hiện tại
      final currentSelection = _expressionController.selection;
      final selectionStart =
          currentSelection.start >= 0
              ? currentSelection.start
              : expression.length;
      final selectionEnd =
          currentSelection.end >= 0 ? currentSelection.end : expression.length;

      String newExpression = '';
      int newCursorPosition = selectionStart;

      switch (btnText) {
        case 'C':
          newExpression = '';
          result = '';
          newCursorPosition = 0;
          break;
        case '=':
          calculator(fromEqual: true);
          return; // Không cần cập nhật vị trí con trỏ
        case '(':
          // Kiểm tra cần thêm dấu nhân không
          if (selectionStart > 0 &&
              !'+-×÷('.contains(expression[selectionStart - 1])) {
            // Chèn '×(' tại vị trí con trỏ
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

        _expressionController.selection = TextSelection.collapsed(
          offset: newCursorPosition,
        );
        _lastKnownSelection = _expressionController.selection;
      } catch (e) {
        isEndCalculation = false;
        result = '';
        expression = '';
        resultCur = '';
        _lastKnownSelection = const TextSelection.collapsed(offset: 0);
        expression += btnText;
      }
    });
  }

  void _updateSelectionPosition() {
    _lastKnownSelection = _expressionController.selection;
  }

  void calculator({bool? fromEqual}) {
    if (fromEqual == true) {
      if (isEndCalculation) {
        return;
      }
      isEndCalculation = true;
      try {
        final parsedExpression = expression
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll('π', '3.1415926535')
            .replaceAll('e', '2.7182818284')
            .replaceAll('√', 'sqrt')
            .replaceAll('∛', 'cbrt')
            .replaceAll('^', 'pow');

        final exp = _parser.parse(parsedExpression);
        final context = ContextModel();
        final eval = exp.evaluate(EvaluationType.REAL, context);
        result = eval.toString();
      } catch (e) {
        result = 'ERROR';
      }
    } else {
      try {
        final parsedExpression = expression
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll('π', '3.1415926535')
            .replaceAll('e', '2.7182818284')
            .replaceAll('√', 'sqrt')
            .replaceAll('∛', 'cbrt')
            .replaceAll('^', 'pow');

        final exp = _parser.parse(parsedExpression);
        final context = ContextModel();
        final eval = exp.evaluate(EvaluationType.REAL, context);
        resultCur = eval.toString();
      } catch (e) {
        resultCur = '';
      }
    }
  }

  void onTapDegRad() {
    setState(() {
      isDegreeMode = !isDegreeMode;
      String newExpression = '';
      for (int i = 0; i < expression.length; i++) {
        final String char = expression[i];
        if (char == 's' && expression.substring(i, i + 4) == 'sin(') {
          newExpression += 'sinRad(';
          i += 3;
        } else if (char == 'c' && expression.substring(i, i + 4) == 'cos(') {
          newExpression += 'cosRad(';
          i += 3;
        } else if (char == 't' && expression.substring(i, i + 4) == 'tan(') {
          newExpression += 'tanRad(';
          i += 3;
        } else {
          newExpression += char;
        }
      }
      expression = newExpression;
    });
  }

  Widget _buildExpressionWithColoredBrackets() {
    if (expression.isEmpty) {
      return const SizedBox();
    }

    final baseStyle = context.textTheme.displayMedium?.copyWith(
      fontSize:
          isEndCalculation
              ? 40
              : expression.length > 10
              ? 40
              : 70,
      height: 1,
      color: context.colorScheme.onSurface.withOpacity(
        isEndCalculation ? 0.5 : 1,
      ),
    );

    if (!expression.contains('(') && !expression.contains(')')) {
      // Không có dấu ngoặc, hiển thị bình thường
      return Text(expression, style: baseStyle, textAlign: TextAlign.end);
    }

    // Đơn giản hóa: Chỉ sử dụng một màu cho tất cả dấu ngoặc
    // vì không có ngoặc lồng ngoặc
    final bracketColor = Colors.blue;

    // Xây dựng spans với màu sắc
    final List<TextSpan> spans = [];
    String currentSegment = '';

    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(' || expression[i] == ')') {
        // Thêm đoạn văn bản trước dấu ngoặc
        if (currentSegment.isNotEmpty) {
          spans.add(TextSpan(text: currentSegment, style: baseStyle));
          currentSegment = '';
        }

        // Thêm dấu ngoặc với màu
        spans.add(
          TextSpan(
            text: expression[i],
            style: baseStyle?.copyWith(
              color: bracketColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        currentSegment += expression[i];
      }
    }

    // Thêm phần còn lại
    if (currentSegment.isNotEmpty) {
      spans.add(TextSpan(text: currentSegment, style: baseStyle));
    }

    return RichText(textAlign: TextAlign.end, text: TextSpan(children: spans));
  }
}

class AllButton extends StatelessWidget {
  const AllButton({
    required this.btnText,
    required this.onAction,
    this.scaleTextSize = 1.5,
    super.key,
  });
  final String btnText;
  final Function(String) onAction;
  final double scaleTextSize;

  @override
  Widget build(BuildContext context) {
    final isOperator = '÷×-+'.contains(btnText);
    final isAction =
        btnText == 'C' ||
        btnText == '=' ||
        btnText == ')' ||
        btnText == '%' ||
        btnText == '(';
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: () => onAction(btnText),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        backgroundColor:
            btnText == '='
                ? colorScheme.primaryContainer
                : isOperator
                ? colorScheme.tertiaryContainer.withOpacity(0.8)
                : isAction
                ? colorScheme.secondaryContainer
                : colorScheme.surfaceVariant,
        foregroundColor:
            btnText == '='
                ? colorScheme.onPrimaryContainer
                : isOperator
                ? colorScheme.tertiary
                : isAction
                ? colorScheme.secondary
                : colorScheme.onSurfaceVariant,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              btnText == 'C'
                  ? BorderSide(
                    color: colorScheme.error.withOpacity(0.5),
                    width: 1.5,
                  )
                  : BorderSide.none,
        ),
      ),
      child: _buildButtonChild(context),
    );
  }

  Widget _buildButtonChild(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (btnText == '-' || btnText == '÷' || btnText == '×' || btnText == '+') {
      // Xử lý các toán tử như cũ
      if (btnText == '-') {
        return Container(
          width: 20 * scaleTextSize,
          height: 3 * scaleTextSize,
          decoration: BoxDecoration(
            color: colorScheme.tertiary,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }
      return Transform.scale(
        scale: 4,
        child: Text(
          btnText,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10 * scaleTextSize,
            fontWeight: FontWeight.w300,
            height: 0,
            color: colorScheme.tertiary,
          ),
        ),
      );
    } else {
      Color textColor;
      if (btnText == '=') {
        textColor = colorScheme.onPrimaryContainer;
      } else if (btnText == 'C') {
        textColor = colorScheme.error;
      } else if (btnText == '(' || btnText == ')' || btnText == '%') {
        textColor = colorScheme.secondary;
      } else if ('0123456789'.contains(btnText)) {
        textColor = colorScheme.onSurfaceVariant;
      } else {
        textColor = colorScheme.onSurfaceVariant;
      }

      // Sử dụng các style từ textTheme
      TextStyle? baseStyle;

      if (btnText == '=') {
        baseStyle = textTheme.titleLarge;
      } else if (btnText == 'C') {
        baseStyle = textTheme.titleMedium;
      } else if ('0123456789'.contains(btnText)) {
        baseStyle = textTheme.headlineSmall;
      } else {
        baseStyle = textTheme.bodyLarge;
      }

      return Text(
        btnText,
        style: baseStyle?.copyWith(
          fontSize: 30 * scaleTextSize,
          fontWeight: btnText == '=' ? FontWeight.bold : FontWeight.normal,
          height: 0,
          color: textColor,
        ),
      );
    }
  }
}
