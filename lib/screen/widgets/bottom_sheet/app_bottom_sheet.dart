import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/core/extensions/num_extension.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/core/firebase/analytics/analytics_util.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/button/app_filled_button.dart';

class AppBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool isScrollControlled = true,
    bool useSafeArea = true,
    Color? backgroundColor,
    double? maxHeight,
    double initialChildSize = 0.5, // Kích thước ban đầu (0.5 = 50% màn hình)
    double minChildSize = 0.25, // Kích thước tối thiểu khi thu nhỏ
    double maxChildSize = 0.95, // Kích thước tối đa khi mở rộng
    String? title,
    String? leftButtonText,
    String? rightButtonText,
    VoidCallback? onRightButton,
    bool enableActions = true,
  }) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      useSafeArea: useSafeArea,
      builder: (context) {
        return SafeArea(
          bottom: false,
          child: DraggableScrollableSheet(
            initialChildSize: initialChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            expand: false,
            snap: true,
            snapSizes: const [0.5, 0.95],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color:
                      backgroundColor ??
                      Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thanh kéo
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 0),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Tiêu đề (nếu có)
                    if (title != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16.p.left,
                          16,
                          16.p.right,
                          0,
                        ),
                        child: Text(
                          title,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16.p.left,
                          8,
                          16.p.right,
                          0,
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          child: child,
                        ),
                      ),
                    ),

                    if (enableActions)
                      SafeArea(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AppFilledButton(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  title: leftButtonText ?? t.close,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.1),
                                  textColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: AppFilledButton(
                                  onTap:
                                      onRightButton ??
                                      () {
                                        Navigator.pop(context);
                                      },
                                  title: rightButtonText ?? t.edit,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Future<void> showFontSelected({required BuildContext context}) async {
    final colorScheme = Theme.of(context).colorScheme;
    final appCubit = getIt<AppCubit>();
    final currentFont = appCubit.state.fontFamily;

    final List<String> availableFonts = [
      AppConst.getPlatformFontFamily(),
      ...AppConst.availableFonts,
    ];
    return AppBottomSheet.show(
      context: context,
      title: t.select_font,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      enableActions: false,
      backgroundColor: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),

          ...availableFonts.map((font) {
            final isSelected = currentFont == font;

            return InkWell(
              onTap: () {
                AnalyticsUtil.logEvent('set_font_family', {'fontFamily': font});
                appCubit.setFontFamily(font);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isSelected
                          ? Border.all(color: colorScheme.primary)
                          : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            font,
                            style: TextStyle(
                              fontFamily: font,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color:
                                  isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            t.sample_text,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 14.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: colorScheme.onPrimary,
                          size: 16.sp,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  static String getScreenName(String? routeName) {
    if (routeName == null) {
      return t.standard_calculator;
    }

    final Map<String, String> screenNames = {
      CalculatorRoute.name: t.standard_calculator,
      UnitConverterRoute.name: t.unit_converter,
      ToolsHubRoute.name: t.utility_calculators,
      BmiCalculatorRoute.name: t.bmi_calculator,
      DiscountCalculatorRoute.name: t.discount_calculator,
      TipCalculatorRoute.name: t.tip_calculator,
      DateCalculatorRoute.name: t.date_calculator,
      LoanCalculatorRoute.name: t.loan_calculator,
      GpaCalculatorRoute.name: t.gpa_calculator,
      AgeCalculatorRoute.name: t.age_calculator,
    };

    return screenNames[routeName] ?? t.standard_calculator;
  }

  static void showDefaultScreenSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appCubit = getIt<AppCubit>();
    final currentDefault = appCubit.state.defaultCalculator;

    // List of available screens with their routes
    final List<Map<String, dynamic>> screens = [
      {
        'name': t.standard_calculator,
        'route': CalculatorRoute.name,
        'icon': Icons.calculate_rounded,
        'color': colorScheme.primary,
      },
      {
        'name': t.unit_converter,
        'route': UnitConverterRoute.name,
        'icon': Icons.straighten_rounded,
        'color': Colors.blue,
      },
      {
        'name': t.utility_calculators,
        'route': ToolsHubRoute.name,
        'icon': Icons.calculate_rounded,
        'color': Colors.indigo,
      },
      {
        'name': t.bmi_calculator,
        'route': BmiCalculatorRoute.name,
        'icon': Icons.monitor_weight_outlined,
        'color': Colors.green,
      },
      {
        'name': t.discount_calculator,
        'route': DiscountCalculatorRoute.name,
        'icon': Icons.percent,
        'color': Colors.purple,
      },
      {
        'name': t.tip_calculator,
        'route': TipCalculatorRoute.name,
        'icon': Icons.payments_outlined,
        'color': Colors.amber,
      },
      {
        'name': t.date_calculator,
        'route': DateCalculatorRoute.name,
        'icon': Icons.date_range,
        'color': Colors.orange,
      },
      {
        'name': t.loan_calculator,
        'route': LoanCalculatorRoute.name,
        'icon': Icons.account_balance_outlined,
        'color': Colors.blueGrey,
      },
      {
        'name': t.gpa_calculator,
        'route': GpaCalculatorRoute.name,
        'icon': Icons.school_outlined,
        'color': Colors.deepPurple,
      },
      {
        'name': t.age_calculator,
        'route': AgeCalculatorRoute.name,
        'icon': Icons.cake_outlined,
        'color': Colors.red,
      },
    ];

    AppBottomSheet.show(
      context: context,
      title: t.choose_startup_screen,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      enableActions: false,
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          // Screen options
          ...screens.map((screen) {
            final bool isSelected =
                currentDefault == screen['route'] ||
                (currentDefault == null && screen['route'] == '/');

            return InkWell(
              onTap: () {
                AnalyticsUtil.logEvent('set_default_calculator', {
                  'routeName': screen['route'] as String,
                });
                final String route = screen['route'] as String;
                appCubit.setDefaultCalculator(route);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isSelected
                          ? Border.all(color: colorScheme.primary)
                          : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: (screen['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        screen['icon'] as IconData,
                        color: screen['color'] as Color,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        screen['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: colorScheme.onPrimary,
                          size: 16.sp,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
