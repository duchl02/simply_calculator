import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/global_variable.dart';

class AppSnackbar extends StatelessWidget {
  const AppSnackbar({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    this.duration = const Duration(seconds: 3),
    super.key,
  });

  final Widget message;
  final Duration duration;
  final Color backgroundColor;
  final IconData icon;

  static void showSuccess({
    required String message,
    IconData icon = Icons.check_circle_outline,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showNotification(
      message: message,
      backgroundColor:
          backgroundColor ?? const Color.fromARGB(255, 25, 139, 28),
      icon: icon,
      duration: duration,
    );
  }

  static void showInfo({
    required String message,
    IconData icon = Icons.info_outline,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showNotification(
      message: message,
      backgroundColor: backgroundColor ?? const Color.fromARGB(255, 57, 66, 73),
      icon: icon,
      duration: duration,
    );
  }

  static void showError({
    required String message,
    IconData icon = Icons.error_outline,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showNotification(
      message: message,
      backgroundColor:
          backgroundColor ?? appContext?.colorScheme.error ?? Colors.red,
      icon: icon,
      duration: duration,
    );
  }

  static void _showNotification({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    showSimpleNotification(
      AppSnackbar(
        message: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        backgroundColor: backgroundColor,
        icon: icon,
        duration: duration,
      ),
      position: NotificationPosition.bottom,
      slideDismissDirection: DismissDirection.up,
      background: Colors.transparent,
      elevation: 0,
      duration: duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideDismissible(
      key: ValueKey(DateTime.now().millisecondsSinceEpoch),
      direction: DismissDirection.up,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Icon(icon, size: 24.w, color: Colors.white),
                SizedBox(width: 16.w),
                Expanded(child: message),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () {
                    OverlaySupportEntry.of(context)?.dismiss();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close,
                      size: 20.w,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
