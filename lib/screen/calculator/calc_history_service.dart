import 'dart:collection';

import 'package:simply_calculator/domain/entities/calc_history_model.dart';
import 'package:simply_calculator/i18n/strings.g.dart';

class CalcHistoryService {
  static Map<String, List<CalcHistoryModel>> groupHistoryByDate(
    List<CalcHistoryModel> historyList,
  ) {
    final Map<String, List<CalcHistoryModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in historyList) {
      final DateTime itemDate =
          DateTime.fromMillisecondsSinceEpoch(item.id) ?? now;
      final itemDay = DateTime(itemDate.year, itemDate.month, itemDate.day);

      String group;
      if (itemDay == today) {
        group = t.today;
      } else if (itemDay == yesterday) {
        group = t.yesterday;
      } else if (today.difference(itemDay).inDays <= 7) {
        group = t.last_7_days;
      } else if (itemDay.year == now.year && itemDay.month == now.month) {
        group = t.this_month;
      } else if (itemDay.year == now.year && itemDay.month == now.month - 1) {
        group = t.last_month;
      } else {
        // Định dạng "Tháng 1, 2023"
        group = '${itemDate.month}/${itemDate.year}';
      }

      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      grouped[group]!.add(item);
    }

    // Tạo LinkedHashMap mới với thứ tự mong muốn
    final orderedGroups = LinkedHashMap<String, List<CalcHistoryModel>>();

    // Thêm các nhóm theo thứ tự ưu tiên
    if (grouped.containsKey(t.today)) {
      orderedGroups[t.today] = grouped[t.today]!;
    }
    if (grouped.containsKey(t.yesterday)) {
      orderedGroups[t.yesterday] = grouped[t.yesterday]!;
    }
    if (grouped.containsKey(t.last_7_days)) {
      orderedGroups[t.last_7_days] = grouped[t.last_7_days]!;
    }
    if (grouped.containsKey(t.this_month)) {
      orderedGroups[t.this_month] = grouped[t.this_month]!;
    }
    if (grouped.containsKey(t.last_month)) {
      orderedGroups[t.last_month] = grouped[t.last_month]!;
    }

    // Thêm các nhóm còn lại
    for (final key in grouped.keys) {
      if (key != t.today &&
          key != t.yesterday &&
          key != t.last_7_days &&
          key != t.this_month &&
          key != t.last_month) {
        orderedGroups[key] = grouped[key]!;
      }
    }

    // Sắp xếp mỗi nhóm theo thời gian (giữ nguyên)
    orderedGroups.forEach((key, value) {
      value.sort((a, b) {
        final dateA = DateTime.fromMillisecondsSinceEpoch(a.id);
        final dateB = DateTime.fromMillisecondsSinceEpoch(b.id);
        return dateB.compareTo(dateA);
      });
    });

    return orderedGroups;
  }
}
