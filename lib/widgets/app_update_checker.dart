import 'dart:io';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class AppUpdateChecker extends StatelessWidget {
  final Widget child;

  const AppUpdateChecker({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(days: 3)),
      child: child,
    );
  }
}
