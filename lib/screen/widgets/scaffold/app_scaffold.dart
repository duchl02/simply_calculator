import 'package:flutter/material.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';

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
  });

  final String? title;
  final Widget? body;
  final List<Widget>? actions;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? persistentFooterButtons;
  final Widget? resizeToAvoidBottomInset;
  final Color? backgroundColor;

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
            actions: actions,
          ),
      body: body,
      drawer: drawer,
      persistentFooterButtons:
          persistentFooterButtons != null ? [persistentFooterButtons!] : null,
      backgroundColor: backgroundColor ?? context.colorScheme.surface,
    );
  }
}
