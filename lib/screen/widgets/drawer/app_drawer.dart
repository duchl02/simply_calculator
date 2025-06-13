import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      width: 0.8.sw,
      backgroundColor: colorScheme.surface,
      elevation: 1,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                AppConst.appName,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            _buildNavItem(
              context,
              Icons.home_outlined,
              t.home,
              selected: true,
              onTap: () {},
            ),
            _buildNavItem(
              context,
              Icons.settings_outlined,
              t.settings,
              onTap: () {
                context.pushRoute(const SettingsRoute());
              },
            ),

            const SizedBox(height: 16),
            _buildSectionTitle(context, 'My favorite'),
            _buildNavItem(
              context,
              Icons.calculate_outlined,
              'Basic Calculator',
            ),
            _buildNavItem(context, Icons.straighten_outlined, 'Unit Converter'),
            _buildNavItem(
              context,
              Icons.attach_money_outlined,
              'Currency Converter',
            ),

            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Others'),
            _buildNavItem(
              context,
              Icons.percent_outlined,
              'Discount Calculator',
            ),
            _buildNavItem(
              context,
              Icons.monetization_on_outlined,
              'Tip Calculator',
            ),
            _buildNavItem(
              context,
              Icons.calendar_today_outlined,
              'Date Calculator',
            ),
            _buildNavItem(
              context,
              Icons.request_page_outlined,
              'Loan Calculator',
            ),
            _buildNavItem(context, Icons.school_outlined, 'GPA Calculator'),
            _buildNavItem(
              context,
              Icons.monitor_weight_outlined,
              'BMI Calculator',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label, {
    bool selected = false,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Material(
        color: selected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      selected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          selected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (!selected)
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
