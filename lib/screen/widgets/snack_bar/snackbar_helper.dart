import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simply_calculator/screen/widgets/snack_bar/app_snackbar.dart';

class SnackbarHelper {
  static void showSuccessTopSnackbar({
    required BuildContext context,
    String? message,
  }) {
    showOverlayNotification((context) {
      return AppSnackbar(
        icon: Icons.check_circle_outline,
        message: Text(message ?? ''),
        backgroundColor: const Color(0xFF43a047),
      );
    }, duration: const Duration(seconds: 2));
  }
}
