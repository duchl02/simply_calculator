import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/core/extensions/string_extension.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/domain/entities/calc_history_model.dart';

class CalcHistoryItem extends StatelessWidget {
  final CalcHistoryModel history;
  final bool isSelected; 

  const CalcHistoryItem({
    required this.history,
    this.isSelected = false, 
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected
                ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
                : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.expression,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onPrimaryContainer.withOpacity(
                      0.6,
                    ),
                  ),
                ),
                Text(
                  history.result.formatAsFixed(),
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          16.horizontalSpace,
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: context.colorScheme.onPrimaryContainer.withOpacity(0.6),
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}
