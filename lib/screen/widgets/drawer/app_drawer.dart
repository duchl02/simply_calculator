import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/gen/assets.gen.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      width: 0.85.sw,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App header with logo and name
                _buildAppHeader(colorScheme),

                SizedBox(height: 24.h),

                // Favorites section
                BlocBuilder<AppCubit, AppState>(
                  builder: (context, state) {
                    if (getIt<AppCubit>().state.favorites.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFavoritesSection(),
                          SizedBox(height: 16.h),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Main Navigation
                _buildSection(
                  [
                    // Calculator (Main)
                    _buildSettingItem(
                      icon: Icons.straighten_rounded,
                      title: t.unit_converter,
                      subtitle: t.convert_between_units,
                      onTap: () {
                        context.pushRoute(const UnitConverterRoute());
                      },
                    ),

                    // Tools Hub - Replaces individual calculator entries
                    _buildSettingItem(
                      title: t.utility_calculators,
                      subtitle: t.utility_calculators_desc,
                      icon: Icons.calculate_rounded,
                      onTap: () {
                        context.pushRoute(const ToolsHubRoute());
                      },
                    ),
                  ],
                  t.tools_hub,
                  Icons.calculate_rounded,
                ),

                SizedBox(height: 16.h),

                // Settings section (thêm accent color cho settings item)
                _buildSection(
                  [
                    // Theme settings
                    _buildSettingItem(
                      icon: Icons.color_lens,
                      title: t.theme_settings,
                      subtitle: t.choose_app_appearance,
                      trailing: _buildColorIndicator(context),
                      onTap: () {
                        context.pushRoute(const ThemeSettingsRoute());
                      },
                    ),

                    // Dark mode toggle
                    _buildSettingItem(
                      title: t.dark_mode,
                      subtitle:
                          getIt<AppCubit>().state.isDarkMode
                              ? t.dark_mode_on
                              : t.dark_mode_off,
                      icon:
                          getIt<AppCubit>().state.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                      trailing: Switch.adaptive(
                        value: getIt<AppCubit>().state.isDarkMode,
                        onChanged: (value) {
                          Future.microtask(
                            () => getIt<AppCubit>().setDarkMode(value),
                          );
                        },
                      ),
                    ),

                    // Language settings
                    _buildSettingItem(
                      icon: Icons.translate,
                      title: t.language,
                      subtitle: t.choose_app_language,
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          AppCubit.getLanguageName(),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        context.pushRoute(const LanguageRoute());
                      },
                    ),

                    // Font settings
                    _buildSettingItem(
                      icon: Icons.font_download_outlined,
                      title: t.font,
                      subtitle: t.choose_app_font,
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          getIt<AppCubit>().state.fontFamily ?? 'Default',
                          style: TextStyle(
                            fontFamily: getIt<AppCubit>().state.fontFamily,
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        AppBottomSheet.showFontSelected(context: context);
                      },
                    ),

                    // Default Startup Screen
                    BlocBuilder<AppCubit, AppState>(
                      builder: (context, state) {
                        return _buildSettingItem(
                          icon: Icons.login_rounded,
                          title: t.default_startup_screen,
                          subtitle: t.choose_startup_screen,
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _getScreenName(
                                getIt<AppCubit>().state.defaultCalculator,
                              ),
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onTap: () {
                            _showDefaultScreenSelector(context);
                          },
                        );
                      },
                    ),
                  ],
                  t.settings,
                  Icons.settings,
                ),

                SizedBox(height: 16.h),

                // Support section
                _buildSection(
                  [
                    // Rate us
                    // _buildSettingItem(
                    //   icon: Icons.star,
                    //   title: t.rate_us,
                    //   subtitle: t.support_by_rating,
                    //   onTap: () {
                    //     showRateAppDialog(context);
                    //   },
                    // ),

                    // Feedback
                    _buildSettingItem(
                      icon: Icons.feedback,
                      title: t.feedback,
                      subtitle: t.send_us_your_feedback,
                      onTap: () {
                        context.pushRoute(const FeedbackRoute());
                      },
                    ),

                    // Privacy policy
                    _buildSettingItem(
                      icon: Icons.privacy_tip,
                      title: t.privacy_policy,
                      subtitle: t.read_our_privacy_policy,
                      onTap: () {
                        launchUrl(
                          Uri.parse(AppConst.privacyPolicy),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                  ],
                  t.about,
                  Icons.info_outline,
                ),

                SizedBox(height: 24.h),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Assets.icons.appIcon.image(width: 64, height: 64),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConst.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                t.simple_powerful_calculator,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection() {
    final appCubit = getIt<AppCubit>();
    final favorites = appCubit.state.favorites;

    return _buildSection(
      favorites
          .map(
            (favorite) => _buildSettingItem(
              icon: favorite.icon,
              title: favorite.title,
              onTap: () {
                context.router.push(NamedRoute(favorite.routeName));
              },
            ),
          )
          .toList(),
      t.favorites,
      Icons.star_rounded,
    );
  }

  Widget _buildSection(
    List<Widget> children,
    String title,
    IconData sectionIcon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            children: [
              Icon(sectionIcon, size: 20, color: colorScheme.primary),
              SizedBox(width: 8.w),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
          ),
          color: colorScheme.surfaceContainer,
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor, // Add this parameter
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24,
          color: iconColor ?? colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle:
          subtitle != null
              ? Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
              : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 28,
          ),
      onTap: onTap,
    );
  }

  Widget _buildColorIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.palette, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          FutureBuilder<String>(
            future: PackageInfo.fromPlatform().then((info) => info.version),
            builder: (context, snapshot) {
              return Text(
                "${t.version} ${snapshot.data ?? 'N/A'}",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
          SizedBox(height: 4.h),
          Text(
            "© 2025 Simply Crafted Studio",
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenName(String? routeName) {
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

  void _showDefaultScreenSelector(BuildContext context) {
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
