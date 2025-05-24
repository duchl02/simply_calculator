import 'package:flutter/material.dart';
import 'package:simply_calculator/core/extensions/string_extension.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/screen/calculator/widgets/colored_brackets_text.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    required this.expressionController,
    required this.expression,
    required this.result,
    required this.resultCur,
    required this.isEndCalculation,
    required this.onExpressionChanged,
    required this.onTap,
    required this.onSelectionChanged,
    super.key,
  });

  final TextEditingController expressionController;
  final String expression;
  final String result;
  final String resultCur;
  final bool isEndCalculation;
  final ValueChanged<String> onExpressionChanged;
  final VoidCallback onTap;
  final Function(TextSelection) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                TextField(
                  controller: expressionController,
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
                      fontSize: _getFontSize(),
                      color: context.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  style: context.textTheme.displayMedium?.copyWith(
                    fontSize: _getFontSize(),
                    height: 1,
                    color: Colors.transparent, // Make text invisible
                  ),
                  keyboardType: TextInputType.none,
                  enableInteractiveSelection: true,
                  onTap: onTap,
                  onChanged: onExpressionChanged,
                ),

                // Layer 2: Colored brackets display (non-editable)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ColoredBracketsText(
                        text: expression,
                        baseStyle: context.textTheme.displayMedium?.copyWith(
                          fontSize: _getFontSize(),
                          height: 1,
                          color: context.colorScheme.onSurface.withOpacity(
                            isEndCalculation ? 0.5 : 1,
                          ),
                        ),
                        bracketColor: Colors.blue,
                        textAlign: TextAlign.end,
                      ),
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
              fontSize: _getResultSize(),
              fontWeight: FontWeight.normal,
              color: context.colorScheme.onSurface.withOpacity(
                isEndCalculation ? 1 : 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getFontSize() {
    return isEndCalculation
        ? 40
        : expression.length > 10
        ? 40
        : 70;
  }

  double _getResultSize() {
    return isEndCalculation
        ? expression.length > 10
            ? 40
            : 70
        : 40;
  }
}
