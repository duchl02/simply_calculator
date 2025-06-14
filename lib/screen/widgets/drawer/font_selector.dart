import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/i18n/strings.g.dart';

class FontSelector extends StatelessWidget {
  const FontSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen:
          (previous, current) => previous.fontFamily != current.fontFamily,
      builder: (context, state) {
        return ListTile(
          leading: const Icon(Icons.font_download_outlined),
          title: Text(t.font),
          subtitle: Text(
            state.fontFamily ?? '',
            style: TextStyle(fontSize: 12.sp),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => FontSelectorDialog(),
            );
          },
        );
      },
    );
  }
}

class FontSelectorDialog extends StatelessWidget {
  FontSelectorDialog({super.key});

  final List<String> availableFonts = [
    'JetBrainsMono',
    'RobotoMono',
    'SourceCodePro',
    'NotoSerif',
    'RobotoSlab',
    'Merriweather',
    'Quicksand',
    'DancingScript',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appCubit = context.read<AppCubit>();

    return AlertDialog(
      title: Text(t.select_font),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: availableFonts.length,
          itemBuilder: (context, index) {
            final font = availableFonts[index];
            final isSelected = appCubit.state.fontFamily == font;

            return InkWell(
              onTap: () {
                appCubit.setFontFamily(font);
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primaryContainer : null,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            font,
                            style: TextStyle(
                              fontFamily: font,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? theme.colorScheme.primary : null,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            t.sample_text,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 12.sp,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
      ],
    );
  }
}
