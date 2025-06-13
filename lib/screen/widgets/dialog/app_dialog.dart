import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/core/extensions/num_extension.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/widgets/button/app_filled_button.dart';

class AppDialog {
  static Future<void> show({
    required BuildContext context,
    Widget? child,
    bool isDismissible = true,
    bool isScrollControlled = true,
    bool useSafeArea = true,
    Color? backgroundColor,
    double? maxHeight,
    String? title,
    String? content,
    String? leftButtonText,
    String? rightButtonText,
    VoidCallback? onRightButton,
  }) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      useSafeArea: useSafeArea,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
              bottom: Radius.circular(16.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (title != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.p.left, 16, 16.p.right, 0),
                  child: Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              24.verticalSpace,
              if (content != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.p.left, 8, 16.p.right, 0),
                  child: Text(
                    content,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              child ?? const SizedBox.shrink(),
              24.verticalSpace,

              SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    boxShadow: [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppFilledButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          title: leftButtonText ?? t.cancel,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.1),
                          textColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: AppFilledButton(
                          onTap:
                              onRightButton ??
                              () {
                                Navigator.pop(context);
                              },
                          title: rightButtonText ?? 'OK',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
