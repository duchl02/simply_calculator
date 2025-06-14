import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';
import 'package:intl/intl.dart';

@RoutePage()
class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 25));
  DateTime _currentDate = DateTime.now();

  // Age calculation results
  int _years = 0;
  int _months = 0;
  int _days = 0;
  int _totalDays = 0;
  String _zodiacSign = '';
  String _chineseZodiac = '';
  String _nextBirthday = '';
  int _daysUntilNextBirthday = 0;

  @override
  void initState() {
    super.initState();
    _calculateAge();
  }

  void _calculateAge() {
    // Ensure the birth date isn't in the future
    if (_birthDate.isAfter(_currentDate)) {
      setState(() {
        _years = 0;
        _months = 0;
        _days = 0;
        _totalDays = 0;
        _zodiacSign = '';
        _chineseZodiac = '';
        _nextBirthday = '';
        _daysUntilNextBirthday = 0;
      });
      return;
    }

    // Calculate age
    int years = _currentDate.year - _birthDate.year;
    int months = _currentDate.month - _birthDate.month;
    int days = _currentDate.day - _birthDate.day;

    // Adjust the months and years if days or months are negative
    if (days < 0) {
      final previousMonth = DateTime(_currentDate.year, _currentDate.month - 1);
      final daysInPreviousMonth = _daysInMonth(
        previousMonth.year,
        previousMonth.month,
      );
      days += daysInPreviousMonth;
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    // Calculate total days (approximate)
    final diff = _currentDate.difference(_birthDate).inDays;

    // Calculate zodiac sign
    final zodiac = _getZodiacSign(_birthDate.day, _birthDate.month);

    // Calculate Chinese zodiac
    final chineseZodiac = _getChineseZodiac(_birthDate.year);

    // Calculate next birthday
    DateTime nextBirthday = DateTime(
      _currentDate.year,
      _birthDate.month,
      _birthDate.day,
    );

    // If the birthday has already passed this year, get next year's birthday
    if (nextBirthday.isBefore(_currentDate) ||
        nextBirthday.isAtSameMomentAs(_currentDate)) {
      nextBirthday = DateTime(
        _currentDate.year + 1,
        _birthDate.month,
        _birthDate.day,
      );
    }

    final daysUntilNextBirthday = nextBirthday.difference(_currentDate).inDays;

    setState(() {
      _years = years;
      _months = months;
      _days = days;
      _totalDays = diff;
      _zodiacSign = zodiac;
      _chineseZodiac = chineseZodiac;
      _nextBirthday = DateFormat.yMMMMd().format(nextBirthday);
      _daysUntilNextBirthday = daysUntilNextBirthday;
    });
  }

  int _daysInMonth(int year, int month) {
    // Use DateTime to calculate days in month (the "0" day of next month is the last day of this month)
    return DateTime(year, month + 1, 0).day;
  }

  String _getZodiacSign(int day, int month) {
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return t.aries;
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return t.taurus;
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return t.gemini;
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return t.cancer;
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return t.leo;
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return t.virgo;
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return t.libra;
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return t.scorpio;
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return t.sagittarius;
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
      return t.capricorn;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18))
      return t.aquarius;
    return t.pisces; // Feb 19 - March 20
  }

  String _getChineseZodiac(int year) {
    final animals = [
      t.monkey,
      t.rooster,
      t.dog,
      t.pig,
      t.rat,
      t.ox,
      t.tiger,
      t.rabbit,
      t.dragon,
      t.snake,
      t.horse,
      t.goat,
    ];
    return animals[(year - 4) % 12];
  }

  String _getZodiacEmoji(String zodiacSign) {
    final Map<String, String> zodiacEmojis = {
      t.aries: '♈',
      t.taurus: '♉',
      t.gemini: '♊',
      t.cancer: '♋',
      t.leo: '♌',
      t.virgo: '♍',
      t.libra: '♎',
      t.scorpio: '♏',
      t.sagittarius: '♐',
      t.capricorn: '♑',
      t.aquarius: '♒',
      t.pisces: '♓',
    };

    return zodiacEmojis[zodiacSign] ?? '';
  }

  String _getChineseZodiacEmoji(String chineseZodiac) {
    final Map<String, String> chineseZodiacEmojis = {
      t.rat: '🐀',
      t.ox: '🐂',
      t.tiger: '🐅',
      t.rabbit: '🐇',
      t.dragon: '🐉',
      t.snake: '🐍',
      t.horse: '🐎',
      t.goat: '🐐',
      t.monkey: '🐒',
      t.rooster: '🐓',
      t.dog: '🐕',
      t.pig: '🐖',
    };

    return chineseZodiacEmojis[chineseZodiac] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: t.age_calculator,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input card
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
                      t.date_of_birth,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Birth date selector
                    InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _birthDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _birthDate = pickedDate;
                          });
                          _calculateAge();
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
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: colorScheme.primary,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat.yMMMMd().format(_birthDate),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.EEEE().format(_birthDate),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Quick age buttons
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildQuickAgeButton('18', colorScheme),
                        _buildQuickAgeButton('21', colorScheme),
                        _buildQuickAgeButton('30', colorScheme),
                        _buildQuickAgeButton('50', colorScheme),
                        _buildQuickAgeButton('65', colorScheme),
                      ],
                    ),

                    Divider(height: 32.h),

                    // Date to calculate age at (default is today)
                    Text(
                      t.calculate_age_at,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Current date selector
                    InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _currentDate,
                          firstDate: _birthDate.add(
                            const Duration(days: 1),
                          ), // Must be after birth date
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _currentDate = pickedDate;
                          });
                          _calculateAge();
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
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: colorScheme.primary,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isToday(_currentDate)
                                        ? t.today
                                        : DateFormat.yMMMMd().format(
                                          _currentDate,
                                        ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.EEEE().format(_currentDate),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Reset to today button
                    if (!_isToday(_currentDate))
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _currentDate = DateTime.now();
                            });
                            _calculateAge();
                          },
                          child: Text(t.reset_to_today),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Results card
            Card(
              elevation: 0,
              color: colorScheme.primaryContainer.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.your_age,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24.h),

                    // Main age display
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAgeUnit(_years, t.years, colorScheme.primary),
                          _buildAgeSeparator(colorScheme),
                          _buildAgeUnit(_months, t.months, colorScheme.primary),
                          _buildAgeSeparator(colorScheme),
                          _buildAgeUnit(_days, t.days, colorScheme.primary),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Total days
                    _buildInfoRow(
                      t.total_days,
                      '$_totalDays',
                      Icons.calendar_month,
                      colorScheme,
                    ),

                    Divider(
                      height: 32.h,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                    ),

                    // Zodiac signs
                    if (_zodiacSign.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.08,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        _getZodiacEmoji(_zodiacSign),
                                        style: TextStyle(fontSize: 36.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        t.zodiac_sign,
                                        style: TextStyle(
                                          color: colorScheme.onPrimaryContainer
                                              .withOpacity(0.7),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _zodiacSign,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 60.h,
                                  width: 1,
                                  color: colorScheme.onPrimaryContainer
                                      .withOpacity(0.2),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        _getChineseZodiacEmoji(_chineseZodiac),
                                        style: TextStyle(fontSize: 36.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        t.chinese_zodiac,
                                        style: TextStyle(
                                          color: colorScheme.onPrimaryContainer
                                              .withOpacity(0.7),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _chineseZodiac,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 16.h),

                    // Next birthday info
                    if (_nextBirthday.isNotEmpty && _isToday(_currentDate)) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.08,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              t.next_birthday,
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.7),
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _nextBirthday,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              t.days_until_birthday(x: _daysUntilNextBirthday),
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '${t.you_will_be} ${_years + 1} ${t.years_old}',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 16.h),

                    // Copy button
                    OutlinedButton.icon(
                      onPressed: () {
                        String result = '''
${t.date_of_birth}: ${DateFormat.yMMMMd().format(_birthDate)}
${t.age}: $_years ${t.years}, $_months ${t.months}, $_days ${t.days}
${t.total_days}: $_totalDays

${t.zodiac_sign}: $_zodiacSign
${t.chinese_zodiac}: $_chineseZodiac
''';

                        if (_isToday(_currentDate)) {
                          result += '''
${t.next_birthday}: $_nextBirthday
${t.days_until_birthday(x: _daysUntilNextBirthday)}
''';
                        }

                        Clipboard.setData(ClipboardData(text: result));
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
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Information card
            Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.age_in_other_units,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Age in other units
                    _buildInfoRow(
                      t.in_weeks,
                      '${(_totalDays / 7).round()}',
                      Icons.calendar_view_week,
                      colorScheme,
                    ),

                    SizedBox(height: 12.h),

                    _buildInfoRow(
                      t.in_hours,
                      '${(_totalDays * 24).round()}',
                      Icons.access_time,
                      colorScheme,
                    ),

                    SizedBox(height: 12.h),

                    _buildInfoRow(
                      t.in_minutes,
                      '${(_totalDays * 24 * 60).round()}',
                      Icons.timer,
                      colorScheme,
                    ),

                    SizedBox(height: 12.h),

                    _buildInfoRow(
                      t.heartbeats,
                      '${(_totalDays * 24 * 60 * 80).round()}',
                      Icons.favorite,
                      colorScheme,
                      valueColor: Colors.red,
                    ),

                    SizedBox(height: 12.h),

                    _buildInfoRow(
                      t.breaths,
                      '${(_totalDays * 24 * 60 * 20).round()}',
                      Icons.air,
                      colorScheme,
                      valueColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeUnit(int value, String unit, Color color) {
    return Container(
      width: 60.w,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(unit, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildAgeSeparator(ColorScheme colorScheme) {
    return SizedBox(
      width: 20.w,
      child: Center(
        child: Text(
          ':',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        SizedBox(width: 8.w),
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAgeButton(String years, ColorScheme colorScheme) {
    final targetDate = DateTime.now().subtract(
      Duration(days: 365 * int.parse(years)),
    );
    final isSelected =
        _birthDate.year == targetDate.year &&
        _birthDate.month == targetDate.month;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          // Set birth date to X years ago, same month and day as today
          _birthDate = targetDate;
        });
        _calculateAge();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isSelected ? colorScheme.onPrimary : colorScheme.primary,
        backgroundColor: isSelected ? colorScheme.primary : null,
        side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: Text('$years ${t.years_old}'),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
