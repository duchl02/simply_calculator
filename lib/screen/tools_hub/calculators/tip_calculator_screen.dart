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

@RoutePage()
class TipCalculatorScreen extends StatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  State<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> {
  // Input values
  final TextEditingController _billController = TextEditingController();
  double _tipPercentage = 18.0;
  int _numberOfPeople = 1;
  bool _roundUp = false;

  // Calculated values
  double _tipAmount = 0.0;
  double _totalAmount = 0.0;
  double _perPersonTip = 0.0;
  double _perPersonTotal = 0.0;

  // Presets for tip percentages
  final List<double> _tipPresets = [15.0, 18.0, 20.0, 25.0];

  @override
  void initState() {
    super.initState();
    _billController.addListener(_calculateTip);
    FeatureTipsManager.markFeatureAsUsed(TipCalculatorRoute.name);
  }

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  void _calculateTip() {
    final billText = _billController.text.trim();
    if (billText.isEmpty) {
      setState(() {
        _tipAmount = 0.0;
        _totalAmount = 0.0;
        _perPersonTip = 0.0;
        _perPersonTotal = 0.0;
      });
      return;
    }

    try {
      final billAmount = double.parse(billText);
      double tipAmount = billAmount * (_tipPercentage / 100);
      double totalAmount = billAmount + tipAmount;

      if (_roundUp) {
        totalAmount = totalAmount.ceilToDouble();
        tipAmount = totalAmount - billAmount;
      }

      setState(() {
        _tipAmount = tipAmount;
        _totalAmount = totalAmount;
        _perPersonTip = tipAmount / _numberOfPeople;
        _perPersonTotal = totalAmount / _numberOfPeople;
      });
    } catch (e) {
      // Handle parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: t.tip_calculator,
      actions: [
        FavoriteButton(
          calculatorItem: FavoriteCalcItem(
            title: t.tip_calculator,
            routeName: const TipCalculatorRoute().routeName,
            icon: Icons.attach_money,
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill Amount Card
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
                      t.bill_amount,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Bill Amount Input
                    TextField(
                      controller: _billController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.attach_money,
                            color: colorScheme.primary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                    ),

                    // Quick buttons
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildAmountButton('10'),
                        _buildAmountButton('20'),
                        _buildAmountButton('50'),
                        _buildAmountButton('100'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Tip Percentage Card
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.tip_percentage,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Text(
                            '${_tipPercentage.round()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Tip slider
                    Slider(
                      value: _tipPercentage,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      label: "${_tipPercentage.round()}%",
                      activeColor: colorScheme.primary,
                      inactiveColor: colorScheme.primary.withOpacity(0.2),
                      onChanged: (value) {
                        setState(() {
                          _tipPercentage = value;
                        });
                        _calculateTip();
                      },
                    ),

                    // Tip presets
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          _tipPresets
                              .map(
                                (percentage) =>
                                    _buildTipPresetButton(percentage),
                              )
                              .toList(),
                    ),

                    // Round up option
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Text(
                          t.round_up_total,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Switch(
                          value: _roundUp,
                          onChanged: (value) {
                            setState(() {
                              _roundUp = value;
                            });
                            _calculateTip();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Split Bill Card
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.split_bill,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people,
                                color: colorScheme.onPrimary,
                                size: 16.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$_numberOfPeople',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Person count control
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed:
                              _numberOfPeople > 1
                                  ? () {
                                    setState(() {
                                      _numberOfPeople--;
                                    });
                                    _calculateTip();
                                  }
                                  : null,
                          icon: Icon(Icons.remove_circle_outline),
                          color:
                              _numberOfPeople > 1
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant.withOpacity(
                                    0.3,
                                  ),
                          iconSize: 32.sp,
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          '$_numberOfPeople',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 16.w),
                        IconButton(
                          onPressed:
                              _numberOfPeople < 50
                                  ? () {
                                    setState(() {
                                      _numberOfPeople++;
                                    });
                                    _calculateTip();
                                  }
                                  : null,
                          icon: Icon(Icons.add_circle_outline),
                          color:
                              _numberOfPeople < 50
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant.withOpacity(
                                    0.3,
                                  ),
                          iconSize: 32.sp,
                        ),
                      ],
                    ),

                    // Quick buttons
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPersonCountButton(2),
                        SizedBox(width: 8.w),
                        _buildPersonCountButton(4),
                        SizedBox(width: 8.w),
                        _buildPersonCountButton(6),
                        SizedBox(width: 8.w),
                        _buildPersonCountButton(8),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Results Card
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
                      t.summary,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24.h),

                    // Per Person section
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                t.per_person,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onPrimaryContainer
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // Tip per person
                          _buildResultRow(
                            t.tip,
                            '\$${_perPersonTip.toStringAsFixed(2)}',
                            colorScheme,
                          ),

                          SizedBox(height: 8.h),

                          // Total per person
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t.total,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                '\$${_perPersonTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Bill total info
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Bill amount
                          _buildResultRow(
                            t.bill_amount,
                            '\$${_billController.text.isEmpty ? "0.00" : _billController.text}',
                            colorScheme,
                          ),

                          SizedBox(height: 8.h),

                          // Tip amount
                          _buildResultRow(
                            '${t.tip} (${_tipPercentage.round()}%)',
                            '\$${_tipAmount.toStringAsFixed(2)}',
                            colorScheme,
                          ),

                          Divider(
                            height: 24.h,
                            color: colorScheme.onPrimaryContainer.withOpacity(
                              0.2,
                            ),
                          ),

                          // Total amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t.total_bill,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                '\$${_totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Copy button
                    SizedBox(height: 16.h),
                    OutlinedButton.icon(
                      onPressed: () {
                        final result = '''
${t.bill_amount}: \$${_billController.text.isEmpty ? "0.00" : _billController.text}
${t.tip} (${_tipPercentage.round()}%): \$${_tipAmount.toStringAsFixed(2)}
${t.total_bill}: \$${_totalAmount.toStringAsFixed(2)}

${t.per_person} (${_numberOfPeople}):
${t.tip}: \$${_perPersonTip.toStringAsFixed(2)}
${t.total}: \$${_perPersonTotal.toStringAsFixed(2)}
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
          ],
        ),
      ),
    );
  }

  // Helper method to build tip preset buttons
  Widget _buildTipPresetButton(double percentage) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _tipPercentage.round() == percentage.round();

    return InkWell(
      onTap: () {
        setState(() {
          _tipPercentage = percentage;
        });
        _calculateTip();
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          '${percentage.round()}%',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  // Helper method to build amount quick button
  Widget _buildAmountButton(String amount) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: () {
        _billController.text = amount;
        _calculateTip();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: Text('\$$amount'),
    );
  }

  // Helper method to build person count buttons
  Widget _buildPersonCountButton(int count) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _numberOfPeople == count;

    return InkWell(
      onTap: () {
        setState(() {
          _numberOfPeople = count;
        });
        _calculateTip();
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  // Helper method to build result rows
  Widget _buildResultRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimaryContainer.withOpacity(0.9),
          ),
        ),
        Text(value, style: TextStyle(color: colorScheme.onPrimaryContainer)),
      ],
    );
  }
}
