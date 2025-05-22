import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppFilledButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final Gradient? gradient;
  final bool isEnabled;
  final Function()? onLongPress;

  const AppFilledButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.height,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.gradient,
    this.isEnabled = true,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Xử lý gradient (nếu có)
    if (gradient != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: isEnabled ? gradient : null,
          borderRadius: borderRadius ?? BorderRadius.circular(24),
        ),
        child: ElevatedButton(
          onPressed: isEnabled ? onTap : null,
          onLongPress: isEnabled ? onLongPress : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.zero,
            minimumSize: Size(width ?? 36, height ?? 36),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(24),
            ),
          ),
          child: Ink(
            height: height,
            width: width,
            padding: padding ?? EdgeInsets.all(12.r),
            child: _buildButtonContent(context),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        onLongPress: isEnabled ? onLongPress : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled
                  ? backgroundColor ?? colorScheme.primary
                  : colorScheme.surfaceVariant,
          foregroundColor:
              isEnabled
                  ? textColor ?? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant.withOpacity(0.6),
          elevation: 1,
          shadowColor: colorScheme.shadow.withOpacity(0.2),
          padding: padding ?? EdgeInsets.all(12.r),
          minimumSize: Size(width ?? 36, height ?? 36),
          maximumSize: width != null ? Size(width!, double.infinity) : null,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(24),
          ),
          textStyle:
              textStyle ??
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) prefixIcon!,
        if (prefixIcon != null) SizedBox(width: 8.w),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    textStyle ??
                    (gradient != null
                        ? textTheme.labelLarge?.copyWith(
                          color:
                              isEnabled
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant.withOpacity(
                                    0.6,
                                  ),
                          fontWeight: FontWeight.w600,
                        )
                        : null),
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: textTheme.bodySmall?.copyWith(
                    color:
                        isEnabled
                            ? (textColor ?? colorScheme.onPrimary).withOpacity(
                              0.8,
                            )
                            : colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (suffixIcon != null) SizedBox(width: 8.w),
        if (suffixIcon != null) suffixIcon!,
      ],
    );
  }
}
