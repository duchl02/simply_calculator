import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/tools_hub/widgets/calculator_card.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';

@RoutePage()
class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.utility_calculators,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            sliver: SliverToBoxAdapter(
              child: Text(
                t.select_calculator_type,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              delegate: SliverChildListDelegate([
                // Discount Calculator
                CalculatorCard(
                  title: t.currency_converter,
                  description: t.convert_between_currencies,
                  icon: Icons.currency_exchange,
                  iconColor: Colors.green,
                  onTap: () {
                    context.pushRoute(const CurrencyConverterRoute());
                  },
                ),
                CalculatorCard(
                  title: t.discount_calculator,
                  description: t.calculate_discounts_and_sales,
                  icon: Icons.percent,
                  iconColor: Colors.purple,
                  onTap:
                      () => context.pushRoute(const DiscountCalculatorRoute()),
                ),

                // Tip Calculator
                CalculatorCard(
                  title: t.tip_calculator,
                  description: t.calculate_tips_and_split_bills,
                  icon: Icons.attach_money,
                  iconColor: Colors.blue,
                  onTap: () => context.pushRoute(const TipCalculatorRoute()),
                ),

                // Date Calculator
                CalculatorCard(
                  title: t.date_calculator,
                  description: t.calculate_date_differences,
                  icon: Icons.calendar_month,
                  iconColor: Colors.orange,
                  onTap: () => context.pushRoute(const DateCalculatorRoute()),
                ),

                // Loan Calculator
                CalculatorCard(
                  title: t.loan_calculator,
                  description: t.calculate_loan_payments,
                  icon: Icons.account_balance,
                  iconColor: Colors.teal,
                  onTap: () => context.pushRoute(const LoanCalculatorRoute()),
                ),

                // GPA Calculator
                CalculatorCard(
                  title: t.gpa_calculator,
                  description: t.calculate_your_gpa,
                  icon: Icons.school,
                  iconColor: Colors.red,
                  onTap: () => context.pushRoute(const GpaCalculatorRoute()),
                ),

                // BMI Calculator
                CalculatorCard(
                  title: t.bmi_calculator,
                  description: t.calculate_body_mass_index,
                  icon: Icons.monitor_weight,
                  iconColor: Colors.amber,
                  onTap: () => context.pushRoute(const BmiCalculatorRoute()),
                ),

                // Age Calculator
                CalculatorCard(
                  title: t.age_calculator,
                  description: t.calculate_exact_age,
                  icon: Icons.cake,
                  iconColor: Colors.pink,
                  onTap: () => context.pushRoute(const AgeCalculatorRoute()),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
