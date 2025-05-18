import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_support/overlay_support.dart';

class AppSnackbar extends StatelessWidget {
  const AppSnackbar({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    super.key,
  });

  final Widget message;
  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SlideDismissible(
      key: const ValueKey(null),
      direction: DismissDirection.up,
      child: Material(
        child: Container(
          width: double.infinity,
          color: backgroundColor,
          child: Column(
            children: [
              SizedBox(height: 44.h),
              Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    icon,
                    size: 24.w,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: message,
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white,
                  )),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
