import 'package:flutter/material.dart';
import 'package:simply_calculator/domain/entities/calc_history_model.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/calculator/widgets/calc_history_item.dart';

class GroupCalcHistoryWidget extends StatelessWidget {
  const GroupCalcHistoryWidget({
    required this.groupedHistory,
    required this.onItemTap,
    this.onItemLongPress,
    this.selectedItems = const [],
    super.key,
  });

  final Map<String, List<CalcHistoryModel>> groupedHistory;
  final Function(CalcHistoryModel item) onItemTap;
  final Function(CalcHistoryModel item)? onItemLongPress;
  final List<CalcHistoryModel> selectedItems;

  @override
  Widget build(BuildContext context) {
    final List<String> groupOrder = [
      'Today',
      'Yesterday',
      'Last 7 Days',
      'This Month',
      'Last Month',
      ...groupedHistory.keys
          .where(
            (key) =>
                key != t.today &&
                key != t.yesterday &&
                key != t.last_7_days &&
                key != t.this_month &&
                key != t.last_month,
          )
          .toList()
        ..sort(),
    ];

    final List<Widget> historyWidgets = [];

    for (int groupIndex = 0; groupIndex < groupOrder.length; groupIndex++) {
      final String groupKey = groupOrder[groupIndex];

      if (groupedHistory.containsKey(groupKey)) {
        final groupItems = groupedHistory[groupKey]!;

        if (groupItems.isNotEmpty) {
          historyWidgets.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    groupKey,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                ...groupItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () => onItemTap(item),
                      onLongPress:
                          onItemLongPress != null
                              ? () => onItemLongPress!(item)
                              : null,
                      borderRadius: BorderRadius.circular(12),
                      child: CalcHistoryItem(
                        history: item,
                        isSelected: selectedItems.any(
                          (selectedItem) => selectedItem.id == item.id,
                        ),
                      ),
                    ),
                  ),
                ),

                if (groupIndex < groupOrder.length - 1 &&
                    groupIndex < groupedHistory.keys.length - 1)
                  const Divider(height: 24),
              ],
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: historyWidgets,
    );
  }
}
