import 'package:flutter/material.dart';

class ColoredBracketsText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final List<Color> bracketColors;
  final TextAlign textAlign;

  const ColoredBracketsText({
    required this.text,
    required this.baseStyle,
    required this.bracketColors,
    this.textAlign = TextAlign.right,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spans = _buildTextSpans(text, baseStyle);
    
    return RichText(
      textAlign: textAlign,
      maxLines: null,
      text: TextSpan(
        children: spans,
      ),
    );
  }

  List<TextSpan> _buildTextSpans(String text, TextStyle style) {
    final List<TextSpan> spans = [];
    final List<int> openBracketIndices = [];
    final Map<int, int> bracketPairs = {}; // Map from open bracket index to close bracket index
    final Map<int, int> bracketLevels = {}; // Map from bracket index to its nesting level
    
    // First pass: identify bracket pairs and their nesting levels
    for (int i = 0; i < text.length; i++) {
      if (text[i] == '(') {
        openBracketIndices.add(i);
      } else if (text[i] == ')' && openBracketIndices.isNotEmpty) {
        final openIndex = openBracketIndices.removeLast();
        bracketPairs[openIndex] = i;
        
        // Assign the same nesting level to both brackets
        final level = openBracketIndices.length;
        bracketLevels[openIndex] = level;
        bracketLevels[i] = level;
      }
    }
    
    // Second pass: build TextSpans with colored brackets
    int currentPos = 0;
    for (int i = 0; i < text.length; i++) {
      if (text[i] == '(' || text[i] == ')') {
        // Add any text before this bracket
        if (i > currentPos) {
          spans.add(TextSpan(
            text: text.substring(currentPos, i),
            style: style,
          ));
        }
        
        // Add the bracket with appropriate color
        final level = bracketLevels[i] ?? 0;
        final colorIndex = level % bracketColors.length;
        
        spans.add(TextSpan(
          text: text[i],
          style: style.copyWith(
            color: bracketColors[colorIndex],
            fontWeight: FontWeight.bold,
          ),
        ));
        
        currentPos = i + 1;
      }
    }
    
    // Add any remaining text after the last bracket
    if (currentPos < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentPos),
        style: style,
      ));
    }
    
    return spans;
  }
}