import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/domain/entities/favorite_calc_item.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/button/favorite_button.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';

@RoutePage()
class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  // List of courses
  final List<Course> _courses = [];

  // Controller for new course input
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _creditHoursController = TextEditingController();

  // Selected GPA scale (4.0 or 4.3 or 5.0)
  double _gpaScale = 4.0;

  // Selected grade for a new course
  String _selectedGrade = 'A';

  // GPA calculation results
  double _gpa = 0.0;
  double _totalCredits = 0.0;
  double _totalPoints = 0.0;

  // Grade scales for different systems
  final Map<String, Map<String, double>> _gradeScales = {
    '4.0': {
      'A': 4.0,
      'A-': 3.7,
      'B+': 3.3,
      'B': 3.0,
      'B-': 2.7,
      'C+': 2.3,
      'C': 2.0,
      'C-': 1.7,
      'D+': 1.3,
      'D': 1.0,
      'D-': 0.7,
      'F': 0.0,
    },
    '4.3': {
      'A+': 4.3,
      'A': 4.0,
      'A-': 3.7,
      'B+': 3.3,
      'B': 3.0,
      'B-': 2.7,
      'C+': 2.3,
      'C': 2.0,
      'C-': 1.7,
      'D+': 1.3,
      'D': 1.0,
      'D-': 0.7,
      'F': 0.0,
    },
    '5.0': {
      'A': 5.0,
      'A-': 4.7,
      'B+': 4.3,
      'B': 4.0,
      'B-': 3.7,
      'C+': 3.3,
      'C': 3.0,
      'C-': 2.7,
      'D+': 2.3,
      'D': 2.0,
      'D-': 1.7,
      'F': 0.0,
    },
  };

  @override
  void initState() {
    super.initState();

    // Add some sample courses for demonstration
    _addSampleCourses();

    // Calculate initial GPA
    _calculateGpa();
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _creditHoursController.dispose();
    super.dispose();
  }

  void _addSampleCourses() {
    _courses.addAll([
      Course(name: t.mathematics, creditHours: 4, grade: 'A'),
      Course(name: t.history, creditHours: 3, grade: 'B+'),
      Course(name: t.computer_science, creditHours: 4, grade: 'A-'),
    ]);
  }

  void _calculateGpa() {
    if (_courses.isEmpty) {
      setState(() {
        _gpa = 0.0;
        _totalCredits = 0.0;
        _totalPoints = 0.0;
      });
      return;
    }

    double totalPoints = 0.0;
    double totalCredits = 0.0;

    final scaleKey = _gpaScale.toString();

    for (final course in _courses) {
      final points =
          _gradeScales[scaleKey]![course.grade]! * course.creditHours;
      totalPoints += points;
      totalCredits += course.creditHours;
    }

    setState(() {
      _totalPoints = totalPoints;
      _totalCredits = totalCredits;
      _gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
    });
  }

  void _addCourse() {
    if (_courseNameController.text.trim().isEmpty ||
        _creditHoursController.text.trim().isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.please_fill_all_fields),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final name = _courseNameController.text.trim();
      final creditHours = double.parse(_creditHoursController.text.trim());

      if (creditHours <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.credit_hours_must_be_positive),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _courses.add(
          Course(name: name, creditHours: creditHours, grade: _selectedGrade),
        );
      });

      // Clear input fields
      _courseNameController.clear();
      _creditHoursController.clear();

      // Recalculate GPA
      _calculateGpa();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.please_enter_valid_credit_hours),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteCourse(int index) {
    setState(() {
      _courses.removeAt(index);
    });

    // Recalculate GPA
    _calculateGpa();
  }

  void _clearAllCourses() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(t.clear_all_courses),
            content: Text(t.clear_all_courses_confirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _courses.clear();
                  });
                  _calculateGpa();
                },
                child: Text(t.clear),
              ),
            ],
          ),
    );
  }

  void _changeGpaScale(double scale) {
    setState(() {
      _gpaScale = scale;
    });

    _calculateGpa();
  }

  String _getGpaEvaluation(double gpa) {
    if (gpa >= 3.7) return t.excellent;
    if (gpa >= 3.0) return t.very_good;
    if (gpa >= 2.7) return t.good;
    if (gpa >= 2.0) return t.satisfactory;
    if (gpa >= 1.0) return t.poor;
    return t.failing;
  }

  Color _getGpaColor(double gpa) {
    if (gpa >= 3.7) return Colors.green;
    if (gpa >= 3.0) return Colors.lightGreen;
    if (gpa >= 2.7) return Colors.amber;
    if (gpa >= 2.0) return Colors.orange;
    if (gpa >= 1.0) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: t.gpa_calculator,
      actions: [
        FavoriteButton(
          calculatorItem: FavoriteCalcItem(
            title: t.gpa_calculator,
            routeName: GpaCalculatorRoute.name,
            icon: Icons.school,
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GPA Scale Selector
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
                      t.gpa_scale,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SegmentedButton<double>(
                      segments: [
                        ButtonSegment<double>(value: 4.0, label: Text('4.0')),
                        ButtonSegment<double>(value: 4.3, label: Text('4.3')),
                        ButtonSegment<double>(value: 5.0, label: Text('5.0')),
                      ],
                      selected: {_gpaScale},
                      onSelectionChanged: (Set<double> selection) {
                        _changeGpaScale(selection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Add Course Card
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
                      t.add_course,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Course Name
                    TextField(
                      controller: _courseNameController,
                      decoration: InputDecoration(
                        labelText: t.course_name,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        prefixIcon: Icon(Icons.book),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Credit Hours and Grade
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Credit Hours
                        Expanded(
                          child: TextField(
                            controller: _creditHoursController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: t.credit_hours,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              prefixIcon: Icon(Icons.timer),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,1}'),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 16.w),

                        // Grade
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGrade,
                            decoration: InputDecoration(
                              labelText: t.grade,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              prefixIcon: Icon(Icons.grade),
                            ),
                            items:
                                _gradeScales[_gpaScale.toString()]!.keys
                                    .map(
                                      (grade) => DropdownMenuItem(
                                        value: grade,
                                        child: Text(grade),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedGrade = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Add Button
                    ElevatedButton.icon(
                      onPressed: _addCourse,
                      icon: Icon(Icons.add),
                      label: Text(t.add_course),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Courses List
            if (_courses.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.courses,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearAllCourses,
                    icon: Icon(Icons.delete, size: 18.sp),
                    label: Text(t.clear_all),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Course cards list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _courses.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  final gradePoints =
                      _gradeScales[_gpaScale.toString()]![course.grade]!;

                  return Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      title: Text(
                        course.name,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${t.credits}: ${course.creditHours} • ${t.grade_points}: $gradePoints',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getGpaColor(gradePoints).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              course.grade,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getGpaColor(gradePoints),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                            ),
                            onPressed: () => _deleteCourse(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64.sp,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      t.no_courses_added,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      t.add_courses_to_calculate,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 12.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24.h),

            // Results Card
            if (_courses.isNotEmpty)
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
                        t.gpa_result,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 24.h),

                      // GPA Value
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getGpaColor(_gpa).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _gpa.toStringAsFixed(2),
                                style: Theme.of(
                                  context,
                                ).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getGpaColor(_gpa),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${t.on_scale} ${_gpaScale.toString()}',
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Performance evaluation
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _getGpaColor(_gpa).withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            _getGpaEvaluation(_gpa),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getGpaColor(_gpa),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Summary info
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
                            // Total courses
                            _buildInfoRow(
                              t.total_courses,
                              _courses.length.toString(),
                              colorScheme,
                            ),

                            SizedBox(height: 8.h),

                            // Total credit hours
                            _buildInfoRow(
                              t.total_credit_hours,
                              _totalCredits.toString(),
                              colorScheme,
                            ),

                            SizedBox(height: 8.h),

                            // Total grade points
                            _buildInfoRow(
                              t.total_grade_points,
                              _totalPoints.toStringAsFixed(1),
                              colorScheme,
                            ),
                          ],
                        ),
                      ),

                      // Copy button
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: () {
                          final result = '''
GPA: ${_gpa.toStringAsFixed(2)} ${t.on_scale} ${_gpaScale.toString()}
${t.performance}: ${_getGpaEvaluation(_gpa)}
${t.total_courses}: ${_courses.length}
${t.total_credit_hours}: $_totalCredits
${t.total_grade_points}: ${_totalPoints.toStringAsFixed(1)}

${t.courses}:
${_courses.map((c) => '${c.name}: ${c.grade} (${c.creditHours} ${t.credits})').join('\n')}
''';
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

            // Info card
            SizedBox(height: 16.h),
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
                      t.what_is_gpa,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      t.gpa_explanation,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      t.grade_scale,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    ..._buildGradeScaleTable(colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimaryContainer.withOpacity(0.9),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGradeScaleTable(ColorScheme colorScheme) {
    final scaleKey = _gpaScale.toString();
    final entries = _gradeScales[scaleKey]!.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return [
      Table(
        border: TableBorder.all(
          color: colorScheme.onSurfaceVariant.withOpacity(0.2),
          width: 1,
          borderRadius: BorderRadius.circular(8.r),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.1),
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                child: Text(
                  t.grade,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                child: Text(
                  t.grade_points,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          ...entries.map(
            (entry) => TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 12.w,
                  ),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: _getGpaColor(entry.value),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 12.w,
                  ),
                  child: Text(
                    entry.value.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }
}

class Course {
  final String name;
  final double creditHours;
  final String grade;

  Course({required this.name, required this.creditHours, required this.grade});
}
