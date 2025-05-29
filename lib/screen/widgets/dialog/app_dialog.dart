import 'package:flutter/material.dart';
import 'package:simply_calculator/core/extensions/num_extension.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/widgets/button/app_filled_button.dart';

class AppDialog {
  static Future<void> show({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool isScrollControlled = true,
    bool useSafeArea = true,
    Color? backgroundColor,
    double? maxHeight,
    String? title,
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
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
              bottom: Radius.circular(16.0)
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.p.left, 16, 16.p.right, 0),
                  child: Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.p.left, 8, 16.p.right, 0),
                  child: child,
                ),
              ),

              SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppFilledButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          title: leftButtonText ?? t.close,
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
                          title: rightButtonText ?? t.edit,
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
