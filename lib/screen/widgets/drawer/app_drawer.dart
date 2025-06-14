import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/gen/assets.gen.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/dialog/feedback_dialog.dart';
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
        child: Icon(icon, size: 24, color: colorScheme.onSecondaryContainer),
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
            "© 2023 Simply Crafted Studio",
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
