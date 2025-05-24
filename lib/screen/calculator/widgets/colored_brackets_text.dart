import 'package:flutter/material.dart';

class ColoredBracketsText extends StatelessWidget {
  const ColoredBracketsText({
    required this.text,
    required this.baseStyle,
    required this.bracketColor,
    this.textAlign = TextAlign.end,
    super.key,
  });

  final String text;
  final TextStyle? baseStyle;
  final Color bracketColor;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox();
    }

    if (!text.contains('(') && !text.contains(')')) {
      // Không có dấu ngoặc, hiển thị bình thường
      return Text(text, style: baseStyle, textAlign: textAlign);
    }

    // Xây dựng spans với màu sắc
    final List<TextSpan> spans = [];
    String currentSegment = '';
    final List<int> openBracketIndices = [];
    final Map<int, int> bracketLevels = {};
    
    // Phân tích cấp độ ngoặc
    for (int i = 0; i < text.length; i++) {
      if (text[i] == '(') {
        openBracketIndices.add(i);
        bracketLevels[i] = openBracketIndices.length - 1;
      } else if (text[i] == ')' && openBracketIndices.isNotEmpty) {
        final level = openBracketIndices.length - 1;
        bracketLevels[i] = level;
        openBracketIndices.removeLast();
      }
    }

    for (int i = 0; i < text.length; i++) {
      if (text[i] == '(' || text[i] == ')') {
        // Thêm đoạn văn bản trước dấu ngoặc
        if (currentSegment.isNotEmpty) {
          spans.add(TextSpan(text: currentSegment, style: baseStyle));
          currentSegment = '';
        }

        // Thêm dấu ngoặc với màu
        spans.add(
          TextSpan(
            text: text[i],
            style: baseStyle?.copyWith(
              color: bracketColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        currentSegment += text[i];
      }
    }

    // Thêm phần còn lại
    if (currentSegment.isNotEmpty) {
      spans.add(TextSpan(text: currentSegment, style: baseStyle));
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(children: spans),
    );
  }
}