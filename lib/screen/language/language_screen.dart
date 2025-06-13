import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';

@RoutePage()
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return AppScaffold(
          title: t.language,
          body: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: AppConst.languages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final lang = AppConst.languages[index];
              final isSelected =
                  lang['code'] == getIt<AppCubit>().state.language;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.colorScheme.surfaceContainer,
                ),
                child: ListTile(
                  leading: Text(
                    lang['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    lang['name']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing:
                      isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey,
                          ),
                  onTap: () {
                    getIt<AppCubit>().setLanguage(lang['code']!);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
