import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/core/extensions/string_extension.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/di/di.dart';
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
    'C',
    '( )',
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
    '00',
    '0',
    ',',
    '=',
  ];

  final List<String> basicButtons = [
    'C',
    '( )',
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
    '00',
    '0',
    ',',
    '=',
  ];
  String result = '';
  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(color: context.colorScheme.surface),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      expression.replaceAll('.', ','),
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "= ${result.formatAsFixed().replaceAll('.', ',')}",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
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
                      isSimple ? 'Nâng cao' : 'Cơ bản',
                      key: ValueKey<bool>(isSimple),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    elevation: 2,
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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

                    expression =
                        expression.length > 1
                            ? expression.substring(0, expression.length - 1)
                            : '';
                    setState(() {});
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
      switch (btnText) {
        case 'C':
          expression = '';
          result = '';
          break;
        case '=':
          try {
            // Chuyển đổi biểu thức sang dạng Dart hiểu được
            final parsedExpression = expression
                .replaceAll('×', '*')
                .replaceAll('÷', '/')
                .replaceAll('π', '3.1415926535')
                .replaceAll('e', '2.7182818284')
                .replaceAll('√', 'sqrt')
                .replaceAll('∛', 'cbrt')
                .replaceAll('^', 'pow');

            // Dùng math_expressions để tính
            final exp = _parser.parse(parsedExpression);
            final context = ContextModel();
            final eval = exp.evaluate(EvaluationType.REAL, context);
            result = eval.toString();
          } catch (e) {
            result = '';
          }
          break;
        case '( )': // Xử lý khi nhấn nút ngoặc kép
          // Đếm số lượng ngoặc mở và đóng trong biểu thức
          int openCount = 0;
          int closeCount = 0;

          for (int i = 0; i < expression.length; i++) {
            if (expression[i] == '(') openCount++;
            if (expression[i] == ')') closeCount++;
          }

          // Kiểm tra xem nên thêm dấu ngoặc nào
          if (openCount > closeCount) {
            // Số ngoặc mở nhiều hơn, thêm ngoặc đóng
            expression += ')';
          } else {
            // Số ngoặc bằng nhau hoặc ít hơn, thêm ngoặc mở
            expression += '(';
          }
          break;
        case 'sin':
        case 'cos':
        case 'tan':
        case 'log':
        case 'ln':
        case '√':
        case '∛':
          expression += '$btnText(';
          break;
        case '!':
          expression += '!';
          break;
        case 'φ':
          expression += '1.6180339887';
          break;
        case '⌫': // Xử lý khi nhấn nút xóa từng ký tự
          if (expression.isNotEmpty) {
            expression = expression.substring(0, expression.length - 1);
            // Nếu đã xóa hết biểu thức, xóa luôn kết quả
            if (expression.isEmpty) {
              result = '';
            }
          }
          break;
        case ',':
          if (!expression.contains(',')) {
            expression += '.';
          }
          break;
        default:
          expression += btnText;
      }
    });
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
        btnText == 'C' || btnText == '=' || btnText == '( )' || btnText == '%';
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
        elevation: btnText == '=' ? 4 : 1,
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

    if (btnText == '-' || btnText == '÷' || btnText == '×' || btnText == '+') {
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
          style: TextStyle(
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
      } else if (btnText == '( )' || btnText == '%') {
        textColor = colorScheme.secondary;
      } else if ('0123456789'.contains(btnText)) {
        textColor = colorScheme.onSurfaceVariant;
      } else {
        textColor = colorScheme.onSurfaceVariant;
      }

      return Text(
        btnText,
        style: TextStyle(
          fontSize: 30 * scaleTextSize,
          fontWeight: btnText == '=' ? FontWeight.bold : FontWeight.normal,
          height: 0,
          color: textColor,
        ),
      );
    }
  }
}
