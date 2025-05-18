import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/global_variable.dart';

class ChangeValueDialog extends StatefulWidget {
  const ChangeValueDialog({
    required this.child,
    required this.onSaveChange,
    this.title,
    this.subtitle,
    this.saveButtonTitle,
    this.hasCloseButton = true,
    this.needPopWhenAccept = true,
    this.hasCancelButton = true,
    this.hasSaveButton = true,
    this.onCancel,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Function() onSaveChange;
  final Function()? onCancel;
  final String? title;
  final String? subtitle;
  final String? saveButtonTitle;
  final bool hasCloseButton;
  final bool needPopWhenAccept;
  final bool hasCancelButton;
  final bool hasSaveButton;

  @override
  State<ChangeValueDialog> createState() => _ChangeValueDialogState();
}

class _ChangeValueDialogState extends State<ChangeValueDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: useMobileLayout ? 30.w : 128.w,
      ),
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(widget.title ?? '', textAlign: TextAlign.center),
                ),
              ],
            ),
            Visibility(
              visible: widget.title != null,
              child: const SizedBox(height: 24),
            ),
            Visibility(
              visible: widget.subtitle != null,
              child: Text(
                widget.subtitle ?? '',
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 8),
            widget.child,
            const SizedBox(height: 24),
            Row(
              children: [
                // Expanded(
                //   child:
                      // widget.hasCancelButton
                          // ? ButtonTextGradient(
                          //   onPressed: () {
                          //     if (widget.onCancel != null) {
                          //       widget.onCancel!();
                          //     } else {
                          //       Navigator.pop(context);
                          //     }
                          //   },
                          //   text: t.core.cancel,
                          // )
                          // : const SizedBox.shrink(),
                // ),
                const SizedBox(width: 16),
                // Expanded(
                //   child:
                //       widget.hasSaveButton
                //           ? ButtonBackgroundGradient(
                //             onPressed: () {
                //               widget.onSaveChange();
                //               if (widget.needPopWhenAccept) {
                //                 Navigator.pop(context);
                //               }
                //             },
                //             text: widget.saveButtonTitle ?? t.core.select,
                //           )
                //           : const SizedBox.shrink(),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
