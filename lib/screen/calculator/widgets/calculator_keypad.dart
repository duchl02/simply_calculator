import 'package:flutter/material.dart';
import 'package:simply_calculator/constants/calculator_constants.dart';
import 'package:simply_calculator/screen/calculator/widgets/calculator_button.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({
    required this.isSimple,
    required this.onButtonPressed,
    required this.scaleTextSize,
    super.key,
  });

  final bool isSimple;
  final Function(String) onButtonPressed;
  final double scaleTextSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttons = isSimple ? CalculatorConstants.basicButtons : CalculatorConstants.allButtons;

        final int crossAxisCount = 4;
        final int rowCount = (buttons.length / crossAxisCount).ceil();

        final double spacing = 8.0;
        final double totalSpacingY = spacing * (rowCount - 1);
        final double totalSpacingX = spacing * (crossAxisCount - 1);

        final double itemHeight = (constraints.maxHeight - totalSpacingY) / rowCount;
        final double itemWidth = (constraints.maxWidth - totalSpacingX) / crossAxisCount;
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
            return CalculatorButton(
              btnText: btnText,
              onAction: onButtonPressed,
              scaleTextSize: scaleTextSize,
            );
          },
        );
      },
    );
  }
}