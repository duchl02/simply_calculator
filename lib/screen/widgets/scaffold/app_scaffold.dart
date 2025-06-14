import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/router/app_router.gr.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.body,
    this.actions,
    this.appBar,
    this.drawer,
    this.persistentFooterButtons,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
    this.hasFeedbackButton = true,
  });

  final String? title;
  final Widget? body;
  final List<Widget>? actions;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? persistentFooterButtons;
  final Widget? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool hasFeedbackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBar ??
          AppBar(
            backgroundColor: backgroundColor ?? context.colorScheme.surface,
            title:
                title != null
                    ? Text(title!, style: context.textTheme.titleLarge)
                    : null,
            actions: [
              if (hasFeedbackButton)
                IconButton(
                  onPressed: () {
                    context.pushRoute(const FeedbackRoute());
                  },
                  icon: const Icon(Icons.bug_report_rounded),
                ),
              if (hasFeedbackButton) 8.horizontalSpace,
              ...actions ?? [],
            ],
          ),
      body: body,
      drawer: drawer,
      persistentFooterButtons:
          persistentFooterButtons != null ? [persistentFooterButtons!] : null,
      backgroundColor: backgroundColor ?? context.colorScheme.surface,
    );
  }
}
