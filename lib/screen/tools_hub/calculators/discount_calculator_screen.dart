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
class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() =>
      _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Input controllers
  final TextEditingController _originalPriceController =
      TextEditingController();
  final TextEditingController _discountPercentController =
      TextEditingController();
  final TextEditingController _finalPriceController = TextEditingController();

  // Tab 1: Calculate Final Price
  double _originalPrice = 0.0;
  double _discountPercent = 0.0;
  double _discountAmount = 0.0;
  double _finalPrice = 0.0;

  // Tab 2: Calculate Original Price
  double _givenFinalPrice = 0.0;
  double _givenDiscountPercent = 0.0;
  double _calculatedOriginalPrice = 0.0;
  double _calculatedDiscountAmount = 0.0;

  // Preset discount percentages
  final List<double> _discountPresets = [
    5.0,
    10.0,
    15.0,
    20.0,
    25.0,
    50.0,
    70.0,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listeners
    _originalPriceController.addListener(_calculateFinalPrice);
    _discountPercentController.addListener(_calculateFinalPrice);
    _finalPriceController.addListener(_calculateOriginalPrice);

    // Default values
    _discountPercentController.text = "20";
  }

  @override
  void dispose() {
    _originalPriceController.dispose();
    _discountPercentController.dispose();
    _finalPriceController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _calculateFinalPrice() {
    final originalPriceText = _originalPriceController.text.trim();
    final discountPercentText = _discountPercentController.text.trim();

    if (originalPriceText.isEmpty || discountPercentText.isEmpty) {
      setState(() {
        _originalPrice = 0.0;
        _discountPercent = 0.0;
        _discountAmount = 0.0;
        _finalPrice = 0.0;
      });
      return;
    }

    try {
      final originalPrice = double.parse(originalPriceText);
      final discountPercent = double.parse(discountPercentText);

      final discountAmount = originalPrice * (discountPercent / 100);
      final finalPrice = originalPrice - discountAmount;

      setState(() {
        _originalPrice = originalPrice;
        _discountPercent = discountPercent;
        _discountAmount = discountAmount;
        _finalPrice = finalPrice;
      });
    } catch (e) {
      // Handle parsing errors
    }
  }

  void _calculateOriginalPrice() {
    final finalPriceText = _finalPriceController.text.trim();
    final discountPercentText = _discountPercentController.text.trim();

    if (finalPriceText.isEmpty || discountPercentText.isEmpty) {
      setState(() {
        _givenFinalPrice = 0.0;
        _givenDiscountPercent = 0.0;
        _calculatedOriginalPrice = 0.0;
        _calculatedDiscountAmount = 0.0;
      });
      return;
    }

    try {
      final finalPrice = double.parse(finalPriceText);
      final discountPercent = double.parse(discountPercentText);

      // Original = Final / (1 - Discount%)
      final originalPrice = finalPrice / (1 - (discountPercent / 100));
      final discountAmount = originalPrice - finalPrice;

      setState(() {
        _givenFinalPrice = finalPrice;
        _givenDiscountPercent = discountPercent;
        _calculatedOriginalPrice = originalPrice;
        _calculatedDiscountAmount = discountAmount;
      });
    } catch (e) {
      // Handle parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: t.discount_calculator,
      actions: [
        FavoriteButton(
          calculatorItem: FavoriteCalcItem(
            title: t.discount_calculator,
            routeName: DiscountCalculatorRoute.name,
            icon: Icons.percent,
          ),
        ),
      ],
      body: Column(
        children: [
          // Tab bar
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: t.calculate_final_price,
                  icon: Icon(Icons.arrow_downward, size: 20.sp),
                ),
                Tab(
                  text: t.calculate_original_price,
                  icon: Icon(Icons.arrow_upward, size: 20.sp),
                ),
              ],
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
              indicatorColor: colorScheme.primary,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Calculate Final Price
                _buildCalculateFinalPriceTab(colorScheme),

                // Tab 2: Calculate Original Price
                _buildCalculateOriginalPriceTab(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Calculate Final Price
  Widget _buildCalculateFinalPriceTab(ColorScheme colorScheme) {
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
                  // Original Price input
                  Text(
                    t.original_price,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _originalPriceController,
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
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                  ),

                  // Quick price buttons
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPriceButton('10'),
                      _buildPriceButton('25'),
                      _buildPriceButton('50'),
                      _buildPriceButton('100'),
                    ],
                  ),

                  // Divider
                  Divider(height: 32.h),

                  // Discount percentage input
                  Text(
                    t.discount_percentage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _discountPercentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Icon(Icons.percent, color: colorScheme.primary),
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

                  // Discount preset buttons
                  SizedBox(height: 12.h),
                  _buildDiscountButtonGrid(colorScheme),
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
                children: [
                  Text(
                    t.results,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 24.h),

                  // Summary section
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        // Original price
                        _buildResultRow(
                          t.original_price,
                          '\$${_originalPrice.toStringAsFixed(2)}',
                          colorScheme,
                        ),

                        SizedBox(height: 12.h),

                        // Discount percentage and amount
                        _buildResultRow(
                          '${t.discount} (${_discountPercent.round()}%)',
                          '- \$${_discountAmount.toStringAsFixed(2)}',
                          colorScheme,
                          valueColor: colorScheme.error,
                        ),

                        Divider(
                          height: 24.h,
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.2,
                          ),
                        ),

                        // Final price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.final_price,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              '\$${_finalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        // You save text
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.error.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                '${t.you_save} \$${_discountAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.error,
                                ),
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
${t.original_price}: \$${_originalPrice.toStringAsFixed(2)}
${t.discount} (${_discountPercent.round()}%): - \$${_discountAmount.toStringAsFixed(2)}
${t.final_price}: \$${_finalPrice.toStringAsFixed(2)}
${t.you_save}: \$${_discountAmount.toStringAsFixed(2)}
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

  // Tab 2: Calculate Original Price
  Widget _buildCalculateOriginalPriceTab(ColorScheme colorScheme) {
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
                  // Final Price input
                  Text(
                    t.final_price_after_discount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _finalPriceController,
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
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                  ),

                  // Quick price buttons
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFinalPriceButton('8.99'),
                      _buildFinalPriceButton('19.99'),
                      _buildFinalPriceButton('39.99'),
                      _buildFinalPriceButton('79.99'),
                    ],
                  ),

                  // Divider
                  Divider(height: 32.h),

                  // Discount percentage input (same as in tab 1)
                  Text(
                    t.discount_percentage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _discountPercentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Icon(Icons.percent, color: colorScheme.primary),
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

                  // Discount preset buttons
                  SizedBox(height: 12.h),
                  _buildDiscountButtonGrid(colorScheme),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Results card for original price calculation
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Text(
                    t.results,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 24.h),

                  // Summary section
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        // Original calculated price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.original_price,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              '\$${_calculatedOriginalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Discount percentage and amount
                        _buildResultRow(
                          '${t.discount} (${_givenDiscountPercent.round()}%)',
                          '- \$${_calculatedDiscountAmount.toStringAsFixed(2)}',
                          colorScheme,
                          valueColor: colorScheme.error,
                        ),

                        Divider(
                          height: 24.h,
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.2,
                          ),
                        ),

                        // Final price (input)
                        _buildResultRow(
                          t.final_price,
                          '\$${_givenFinalPrice.toStringAsFixed(2)}',
                          colorScheme,
                        ),

                        // You paid text
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${t.original_price_explanation}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.8,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Copy button
                  SizedBox(height: 16.h),
                  OutlinedButton.icon(
                    onPressed: () {
                      final result = '''
${t.original_price}: \$${_calculatedOriginalPrice.toStringAsFixed(2)}
${t.discount} (${_givenDiscountPercent.round()}%): - \$${_calculatedDiscountAmount.toStringAsFixed(2)}
${t.final_price}: \$${_givenFinalPrice.toStringAsFixed(2)}
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

  // Helper method to build discount buttons grid
  Widget _buildDiscountButtonGrid(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.center,
      children:
          _discountPresets.map((percent) {
            final isSelected =
                _discountPercentController.text == percent.round().toString();
            return InkWell(
              onTap: () {
                _discountPercentController.text = percent.round().toString();
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.primary : colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${percent.round()}%',
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // Helper method to build price buttons
  Widget _buildPriceButton(String price) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: () {
        _originalPriceController.text = price;
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: Text('\$$price'),
    );
  }

  // Helper method to build final price buttons
  Widget _buildFinalPriceButton(String price) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: () {
        _finalPriceController.text = price;
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: Text('\$$price'),
    );
  }

  // Helper method to build result rows
  Widget _buildResultRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    Color? valueColor,
  }) {
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
          style: TextStyle(color: valueColor ?? colorScheme.onPrimaryContainer),
        ),
      ],
    );
  }
}
