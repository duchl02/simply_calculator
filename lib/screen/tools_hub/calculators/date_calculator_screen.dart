import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/core/managers/feature_tips_manager.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/domain/entities/favorite_calc_item.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/button/favorite_button.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Date Difference
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int _dateDifference = 30;

  // Add/Subtract
  DateTime _baseDate = DateTime.now();
  int _years = 0;
  int _months = 0;
  int _days = 0;
  DateTime _resultDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _calculateDifference();
    _calculateDate();
    FeatureTipsManager.markFeatureAsUsed(DateCalculatorRoute.name);

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateDifference() {
    setState(() {
      _dateDifference = _endDate.difference(_startDate).inDays;
    });
  }

  void _calculateDate() {
    setState(() {
      _resultDate = DateTime(
        _baseDate.year + _years,
        _baseDate.month + _months,
        _baseDate.day + _days,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: t.date_calculator,
      actions: [
        FavoriteButton(
          calculatorItem: FavoriteCalcItem(
            title: t.date_calculator,
            routeName: DateCalculatorRoute.name,
            icon: Icons.calendar_month,
          ),
        ),
      ],
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.date_range), text: t.difference),
              Tab(icon: Icon(Icons.add_alarm), text: t.add_subtract),
            ],
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant.withOpacity(0.7),
            indicatorColor: colorScheme.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDateDifferenceTab(colorScheme),
                _buildDateAddSubtractTab(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDifferenceTab(ColorScheme colorScheme) {
    final dateFormat = DateFormat.yMMMMd();
    final weekdayFormat = DateFormat.EEEE();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input section
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.select_dates,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Start date
                  _buildDateSelector(
                    label: t.start_date,
                    date: _startDate,
                    onDateSelected: (date) {
                      setState(() {
                        _startDate = date;
                      });
                      _calculateDifference();
                    },
                  ),
                  SizedBox(height: 16.h),

                  // End date
                  _buildDateSelector(
                    label: t.end_date,
                    date: _endDate,
                    onDateSelected: (date) {
                      setState(() {
                        _endDate = date;
                      });
                      _calculateDifference();
                    },
                  ),

                  // Quick buttons
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickButton(t.today, () {
                        setState(() {
                          _startDate = DateTime.now();
                        });
                        _calculateDifference();
                      }),
                      _buildQuickButton(t.tomorrow, () {
                        setState(() {
                          _endDate = DateTime.now().add(
                            const Duration(days: 1),
                          );
                        });
                        _calculateDifference();
                      }),
                      _buildQuickButton(t.next_week, () {
                        setState(() {
                          _endDate = DateTime.now().add(
                            const Duration(days: 7),
                          );
                        });
                        _calculateDifference();
                      }),
                      _buildQuickButton(t.next_month, () {
                        setState(() {
                          _endDate = DateTime(
                            DateTime.now().year,
                            DateTime.now().month + 1,
                            DateTime.now().day,
                          );
                        });
                        _calculateDifference();
                      }),
                      _buildQuickButton(t.next_year, () {
                        setState(() {
                          _endDate = DateTime(
                            DateTime.now().year + 1,
                            DateTime.now().month,
                            DateTime.now().day,
                          );
                        });
                        _calculateDifference();
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Results section
          Card(
            margin: EdgeInsets.only(top: 24.h),
            elevation: 0,
            color: colorScheme.primaryContainer.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    t.date_difference,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Start date info
                  _buildDateInfo(
                    label: t.start_date,
                    date: _startDate,
                    colorScheme: colorScheme,
                  ),

                  // Arrow separator
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Icon(
                      Icons.arrow_downward,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.6),
                    ),
                  ),

                  // End date info
                  _buildDateInfo(
                    label: t.end_date,
                    date: _endDate,
                    colorScheme: colorScheme,
                  ),

                  Divider(
                    height: 32.h,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                  ),

                  // Difference result
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_dateDifference',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _dateDifference == 1 ? t.day : t.days,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),
                  Text(
                    _formatDuration(_dateDifference),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAddSubtractTab(ColorScheme colorScheme) {
    final dateFormat = DateFormat.yMMMMd();
    final weekdayFormat = DateFormat.EEEE();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input section
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        t.base_date,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _baseDate = DateTime.now();
                          });
                          _calculateDate();
                        },
                        icon: Icon(Icons.today, size: 16.sp),
                        label: Text(t.today),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Base date selector
                  InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _baseDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _baseDate = date;
                        });
                        _calculateDate();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateFormat.format(_baseDate),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                weekdayFormat.format(_baseDate),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                  Text(
                    t.add_or_subtract,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Time units
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeUnitInput(
                          label: t.years,
                          value: _years,
                          onChanged: (value) {
                            setState(() {
                              _years = value;
                            });
                            _calculateDate();
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTimeUnitInput(
                          label: t.months,
                          value: _months,
                          onChanged: (value) {
                            setState(() {
                              _months = value;
                            });
                            _calculateDate();
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTimeUnitInput(
                          label: t.days,
                          value: _days,
                          onChanged: (value) {
                            setState(() {
                              _days = value;
                            });
                            _calculateDate();
                          },
                        ),
                      ),
                    ],
                  ),

                  // Quick buttons for addition/subtraction
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickButton('+1 ${t.day}', () {
                        setState(() {
                          _days++;
                        });
                        _calculateDate();
                      }),
                      _buildQuickButton('+7 ${t.days}', () {
                        setState(() {
                          _days += 7;
                        });
                        _calculateDate();
                      }),
                      _buildQuickButton('+30 ${t.days}', () {
                        setState(() {
                          _days += 30;
                        });
                        _calculateDate();
                      }),
                      _buildQuickButton('+1 ${t.year}', () {
                        setState(() {
                          _years++;
                        });
                        _calculateDate();
                      }),
                      _buildQuickButton('-1 ${t.day}', () {
                        setState(() {
                          _days--;
                        });
                        _calculateDate();
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Result section
          Card(
            margin: EdgeInsets.only(top: 24.h),
            elevation: 0,
            color: colorScheme.primaryContainer.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    t.result_date,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Base date info
                  _buildDateInfo(
                    label: t.base_date,
                    date: _baseDate,
                    colorScheme: colorScheme,
                  ),

                  // Show operation
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_years != 0)
                          Text(
                            '${_years > 0 ? "+" : ""}$_years ${_years == 1 ? t.year : t.years}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        if (_years != 0 && (_months != 0 || _days != 0))
                          Text(
                            ', ',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        if (_months != 0)
                          Text(
                            '${_months > 0 ? "+" : ""}$_months ${_months == 1 ? t.month : t.months}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        if (_months != 0 && _days != 0)
                          Text(
                            ', ',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        if (_days != 0)
                          Text(
                            '${_days > 0 ? "+" : ""}$_days ${_days == 1 ? t.day : t.days}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        if (_years == 0 && _months == 0 && _days == 0)
                          Text(
                            t.no_change,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 32.h,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                  ),

                  // Result date
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat.yMMMMd().format(_resultDate),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          DateFormat.EEEE().format(_resultDate),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer.withOpacity(
                              0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Copy button
                  SizedBox(height: 16.h),
                  OutlinedButton.icon(
                    onPressed: () {
                      final resultText = DateFormat(
                        'EEEE, MMMM d, y',
                      ).format(_resultDate);
                      Clipboard.setData(ClipboardData(text: resultText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.copied_to_clipboard),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(Icons.copy, size: 18.sp),
                    label: Text(t.copy_result),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimaryContainer,
                      side: BorderSide(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build date selector
  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required Function(DateTime) onDateSelected,
  }) {
    final dateFormat = DateFormat.yMMMMd();
    final weekdayFormat = DateFormat.EEEE();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: colorScheme.primary),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(date),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        weekdayFormat.format(date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build time unit input field
  Widget _buildTimeUnitInput({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus button
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () {
                  onChanged(value - 1);
                },
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.remove,
                    size: 20.sp,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              // Input field
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: value.toString()),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      onChanged(int.parse(text));
                    } else {
                      onChanged(0);
                    }
                  },
                ),
              ),

              // Plus button
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () {
                  onChanged(value + 1);
                },
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.add,
                    size: 20.sp,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build a quick button
  Widget _buildQuickButton(String label, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: Text(label),
    );
  }

  // Helper method to build date info display
  Widget _buildDateInfo({
    required String label,
    required DateTime date,
    required ColorScheme colorScheme,
  }) {
    final dateFormat = DateFormat.yMMMMd();
    final weekdayFormat = DateFormat.EEEE();

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          dateFormat.format(date),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          weekdayFormat.format(date),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // Helper method to format duration for displaying
  String _formatDuration(int days) {
    if (days <= 0) return '';

    final years = days ~/ 365;
    final months = (days % 365) ~/ 30;
    final remainingDays = days % 30;

    String result = '';
    if (years > 0) {
      result += '$years ${years == 1 ? t.year : t.years}';
    }
    if (months > 0) {
      if (result.isNotEmpty) result += ', ';
      result += '$months ${months == 1 ? t.month : t.months}';
    }
    if (remainingDays > 0 || (years == 0 && months == 0)) {
      if (result.isNotEmpty) result += ', ';
      result += '$remainingDays ${remainingDays == 1 ? t.day : t.days}';
    }

    return result;
  }
}
