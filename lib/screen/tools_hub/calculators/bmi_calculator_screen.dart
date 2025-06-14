import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/domain/entities/favorite_calc_item.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';
import 'package:simply_calculator/screen/widgets/button/favorite_button.dart';

@RoutePage()
class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Metric units
  final TextEditingController _heightCmController = TextEditingController();
  final TextEditingController _weightKgController = TextEditingController();

  // Imperial units
  final TextEditingController _heightFtController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();
  final TextEditingController _weightLbController = TextEditingController();

  // Calculated values
  double _bmi = 0.0;
  String _category = "";
  Color _categoryColor = Colors.grey;

  // Gender selection (affects interpretation slightly)
  bool _isMale = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listeners
    _heightCmController.addListener(_calculateMetricBMI);
    _weightKgController.addListener(_calculateMetricBMI);
    _heightFtController.addListener(_calculateImperialBMI);
    _heightInController.addListener(_calculateImperialBMI);
    _weightLbController.addListener(_calculateImperialBMI);

    // Default values for better UX
    _heightCmController.text = "170";
    _weightKgController.text = "70";
    _heightFtController.text = "5";
    _heightInController.text = "7";
    _weightLbController.text = "154";

    // Initial calculation
    _calculateMetricBMI();
  }

  @override
  void dispose() {
    _heightCmController.dispose();
    _weightKgController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _weightLbController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _calculateMetricBMI() {
    final heightText = _heightCmController.text.trim();
    final weightText = _weightKgController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty) {
      _setBmiResult(0.0);
      return;
    }

    try {
      final height = double.parse(heightText) / 100; // cm to m
      final weight = double.parse(weightText);

      if (height <= 0 || weight <= 0) {
        _setBmiResult(0.0);
        return;
      }

      final bmi = weight / (height * height);
      _setBmiResult(bmi);
    } catch (e) {
      _setBmiResult(0.0);
    }
  }

  void _calculateImperialBMI() {
    final heightFtText = _heightFtController.text.trim();
    final heightInText = _heightInController.text.trim();
    final weightText = _weightLbController.text.trim();

    if (heightFtText.isEmpty || weightText.isEmpty) {
      _setBmiResult(0.0);
      return;
    }

    try {
      final heightFt = int.parse(heightFtText);
      final heightIn = int.parse(heightInText.isEmpty ? '0' : heightInText);
      final totalInches = (heightFt * 12) + heightIn;
      final weight = double.parse(weightText);

      if (totalInches <= 0 || weight <= 0) {
        _setBmiResult(0.0);
        return;
      }

      // BMI formula for imperial units: (weight in pounds * 703) / (height in inches)²
      final bmi = (weight * 703) / (totalInches * totalInches);
      _setBmiResult(bmi);
    } catch (e) {
      _setBmiResult(0.0);
    }
  }

  void _setBmiResult(double bmi) {
    setState(() {
      _bmi = bmi;

      if (bmi <= 0) {
        _category = t.enter_valid_values;
        _categoryColor = Colors.grey;
      } else if (bmi < 18.5) {
        _category = t.underweight;
        _categoryColor = Colors.blue;
      } else if (bmi < 25) {
        _category = t.normal;
        _categoryColor = Colors.green;
      } else if (bmi < 30) {
        _category = t.overweight;
        _categoryColor = Colors.orange;
      } else {
        _category = t.obese;
        _categoryColor = Colors.red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: t.bmi_calculator,
      actions: [
        FavoriteButton(
          calculatorItem: FavoriteCalcItem(
            title: t.bmi_calculator,
            routeName: const BmiCalculatorRoute().routeName,
            icon: Icons.monitor_weight,
          ),
        ),
      ],
      body: Column(
        children: [
          // Gender Selection
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            color: colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.gender,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 16.w),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text(t.male),
                      icon: Icon(Icons.male),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text(t.female),
                      icon: Icon(Icons.female),
                    ),
                  ],
                  selected: {_isMale},
                  onSelectionChanged: (Set<bool> selected) {
                    setState(() {
                      _isMale = selected.first;
                    });
                  },
                ),
              ],
            ),
          ),

          // Unit system tabs
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: t.metric, icon: Icon(Icons.straighten, size: 20.sp)),
                Tab(
                  text: t.imperial,
                  icon: Icon(Icons.straighten, size: 20.sp),
                ),
              ],
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
              indicatorColor: colorScheme.primary,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              onTap: (index) {
                // Recalculate when switching tabs
                if (index == 0) {
                  _calculateMetricBMI();
                } else {
                  _calculateImperialBMI();
                }
              },
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Metric System (cm/kg)
                _buildMetricInputs(colorScheme),

                // Imperial System (ft-in/lb)
                _buildImperialInputs(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Metric System Inputs
  Widget _buildMetricInputs(ColorScheme colorScheme) {
    return SingleChildScrollView(
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
                  // Height input (cm)
                  Text(
                    t.height,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _heightCmController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '170',
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'cm',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 16.w,
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  // Quick height buttons
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickCmButton('160'),
                      _buildQuickCmButton('170'),
                      _buildQuickCmButton('180'),
                      _buildQuickCmButton('190'),
                    ],
                  ),

                  // Divider
                  Divider(height: 32.h),

                  // Weight input (kg)
                  Text(
                    t.weight,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _weightKgController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: '70',
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'kg',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 16.w,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,1}'),
                      ),
                    ],
                  ),

                  // Quick weight buttons
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickKgButton('60'),
                      _buildQuickKgButton('70'),
                      _buildQuickKgButton('80'),
                      _buildQuickKgButton('90'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Results card
          _buildResultsCard(colorScheme),

          SizedBox(height: 16.h),

          // BMI Information
          _buildBmiInfoCard(colorScheme),
        ],
      ),
    );
  }

  // Imperial System Inputs
  Widget _buildImperialInputs(ColorScheme colorScheme) {
    return SingleChildScrollView(
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
                  // Height input (feet and inches)
                  Text(
                    t.height,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      // Feet input
                      Expanded(
                        child: TextField(
                          controller: _heightFtController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '5',
                            suffixIcon: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                'ft',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 14.h,
                              horizontal: 16.w,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // Inches input
                      Expanded(
                        child: TextField(
                          controller: _heightInController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            suffixIcon: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                'in',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 14.h,
                              horizontal: 16.w,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Quick height buttons
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickHeightButton('5', '3'),
                      _buildQuickHeightButton('5', '7'),
                      _buildQuickHeightButton('5', '11'),
                      _buildQuickHeightButton('6', '2'),
                    ],
                  ),

                  // Divider
                  Divider(height: 32.h),

                  // Weight input (lb)
                  Text(
                    t.weight,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _weightLbController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '150',
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'lb',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 16.w,
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  // Quick weight buttons
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickLbButton('130'),
                      _buildQuickLbButton('150'),
                      _buildQuickLbButton('170'),
                      _buildQuickLbButton('190'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Results card (same as metric)
          _buildResultsCard(colorScheme),

          SizedBox(height: 16.h),

          // BMI Information (same as metric)
          _buildBmiInfoCard(colorScheme),
        ],
      ),
    );
  }

  // Results Card (shared between tabs)
  Widget _buildResultsCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              t.your_bmi,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // BMI Value
            Text(
              _bmi > 0 ? _bmi.toStringAsFixed(1) : "—",
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    _bmi > 0 ? _categoryColor : colorScheme.onPrimaryContainer,
              ),
            ),

            SizedBox(height: 16.h),

            // BMI Category
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              decoration: BoxDecoration(
                color:
                    _bmi > 0
                        ? _categoryColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: _bmi > 0 ? _categoryColor : Colors.grey,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // BMI Scale
            Container(
              height: 24.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.red,
                  ],
                  stops: [0.185, 0.25, 0.30, 0.5],
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Scale labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '16',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                Text(
                  '18.5',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                Text(
                  '25',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                Text(
                  '30',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                Text(
                  '40',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            // BMI indicator
            if (_bmi > 0) ...[
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment(
                  // Scale from -1 to 1 based on BMI value (16 to 40)
                  (_bmi - 16) / (40 - 16) * 2 - 1,
                  0,
                ),
                child: Icon(
                  Icons.arrow_drop_up,
                  color: _categoryColor,
                  size: 32.sp,
                ),
              ),
            ],

            // Copy button
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed:
                  _bmi > 0
                      ? () {
                        final result = '''
BMI: ${_bmi.toStringAsFixed(1)}
${t.category}: $_category
''';
                        Clipboard.setData(ClipboardData(text: result));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.copied_to_clipboard),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      : null,
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
    );
  }

  // BMI Information Card
  Widget _buildBmiInfoCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.what_is_bmi,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              t.bmi_explanation,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                height: 1.5,
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              t.bmi_categories,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 8.h),

            // BMI categories
            _buildCategoryItem(
              t.underweight,
              '< 18.5',
              Colors.blue,
              colorScheme,
            ),
            SizedBox(height: 4.h),
            _buildCategoryItem(
              t.normal,
              '18.5 - 24.9',
              Colors.green,
              colorScheme,
            ),
            SizedBox(height: 4.h),
            _buildCategoryItem(
              t.overweight,
              '25 - 29.9',
              Colors.orange,
              colorScheme,
            ),
            SizedBox(height: 4.h),
            _buildCategoryItem(t.obese, '≥ 30', Colors.red, colorScheme),

            SizedBox(height: 16.h),

            Text(
              t.bmi_disclaimer,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build category items in the info card
  Widget _buildCategoryItem(
    String category,
    String range,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            category,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          range,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // Helper methods to build quick buttons
  Widget _buildQuickCmButton(String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _heightCmController.text == value;

    return OutlinedButton(
      onPressed: () {
        _heightCmController.text = value;
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
      child: Text('$value cm'),
    );
  }

  Widget _buildQuickKgButton(String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _weightKgController.text == value;

    return OutlinedButton(
      onPressed: () {
        _weightKgController.text = value;
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
      child: Text('$value kg'),
    );
  }

  Widget _buildQuickHeightButton(String ft, String inch) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected =
        _heightFtController.text == ft && _heightInController.text == inch;

    return OutlinedButton(
      onPressed: () {
        _heightFtController.text = ft;
        _heightInController.text = inch;
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
      child: Text("$ft'$inch\""),
    );
  }

  Widget _buildQuickLbButton(String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _weightLbController.text == value;

    return OutlinedButton(
      onPressed: () {
        _weightLbController.text = value;
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
      child: Text('$value lb'),
    );
  }
}
