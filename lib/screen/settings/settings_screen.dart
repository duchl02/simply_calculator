import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/dialog/feedback_dialog.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSection([
                _buildSettingItem(
                  icon: Icons.calculate_outlined,
                  title: t.calculator_settings,
                  onTap: () {
                    context.pushRoute(const CalculatorSettingsRoute());
                  },
                ),
                _buildSettingItem(
                  icon: Icons.language_outlined,
                  title: t.language,
                  trailing: Text(
                    AppCubit.getLanguageName(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    context.pushRoute(const LanguageRoute());
                  },
                ),
                _buildSettingItem(
                  icon: Icons.star_outline,
                  title: t.rate_us,
                  onTap: () {
                    showRateAppDialog(context);
                  },
                ),
                _buildSettingItem(
                  icon: Icons.feedback_outlined,
                  title: t.feedback,
                  onTap: () {
                    context.pushRoute(const FeedbackRoute());
                  },
                ),
                _buildSettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: t.privacy_policy,
                  onTap: () {
                    launchUrl(
                      Uri.parse(AppConst.privacyPolicy),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ], t.general_setting),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              width: 0.5,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainer,
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.secondaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      onTap: onTap,
    );
  }
}
