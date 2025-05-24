import 'package:flutter/material.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
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