import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/core/firebase/analytics/analytics_util.dart';
import 'package:simply_calculator/core/managers/feature_tips_manager.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';
import 'package:simply_calculator/screen/widgets/snack_bar/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    FeatureTipsManager.markFeatureAsUsed(SettingsRoute.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: t.settings,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              _buildSectionTitle(t.appearance, Icons.color_lens),
              _buildCard([
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
              ]),

              SizedBox(height: 16.h),

              // Personalization Section
              _buildSectionTitle(t.personalization, Icons.person_outline),
              _buildCard([
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
              ]),

              SizedBox(height: 16.h),

              // Behavior Section
              _buildSectionTitle(t.behavior, Icons.auto_awesome),
              _buildCard([
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
                          AppBottomSheet.getScreenName(
                            getIt<AppCubit>().state.defaultCalculator,
                          ),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        AppBottomSheet.showDefaultScreenSelector(context);
                      },
                    );
                  },
                ),
              ]),

              SizedBox(height: 16.h),

              // System Information Section
              _buildSectionTitle(t.system, Icons.info_outline),
              _buildCard([
                // Check for updates
                _buildSettingItem(
                  icon: Icons.system_update_outlined,
                  title: t.check_for_updates,
                  subtitle: t.check_for_new_version,
                  onTap: () {
                    AnalyticsUtil.logEvent('settings_check_for_updates');
                    _showUpdateChecker(context);
                  },
                ),

                // Privacy policy
                _buildSettingItem(
                  icon: Icons.privacy_tip,
                  title: t.privacy_policy,
                  subtitle: t.read_our_privacy_policy,
                  onTap: () {
                    AnalyticsUtil.logEvent('settings_privacy_policy');
                    launchUrl(
                      Uri.parse(AppConst.privacyPolicy),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),

                // Feedback
                _buildSettingItem(
                  icon: Icons.feedback,
                  title: t.feedback,
                  subtitle: t.send_us_your_feedback,
                  onTap: () {
                    AnalyticsUtil.logEvent('settings_feedback');
                    context.pushRoute(const FeedbackRoute());
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
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
    );
  }

  Widget _buildCard(List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
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
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
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

  void _showUpdateChecker(BuildContext context) {
    AppSnackbar.showInfo(message: t.up_to_date);
  }
}
