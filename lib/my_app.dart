import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/core/style/app_theme.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/global_variable.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.dart';
import 'package:simply_calculator/router/app_router_observer.dart';
import 'package:simply_calculator/widgets/app_update_checker.dart';

import 'core/style/flex_color_scheme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = getIt<AppRouter>();
  late final appCubit;

  @override
  void initState() {
    super.initState();
    appCubit = getIt<AppCubit>();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    useMobileLayout = width < 600;

    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize:
          useMobileLayout
              ? const Size(390, 844)
              : const Size(1024 / 1.5, 1366 / 1.5),
      child: OverlaySupport.global(
        child: MultiBlocProvider(
          providers: [BlocProvider<AppCubit>.value(value: appCubit)],
          child: BlocBuilder<AppCubit, AppState>(
            buildWhen: (previous, current) {
              return previous.language != current.language ||
                  previous.theme != current.theme ||
                  previous.isDarkMode != current.isDarkMode ||
                  previous.fontFamily != current.fontFamily;
            },
            builder: (context, state) {
              appContext = context;

              return AppUpdateChecker(
                child: MaterialApp.router(
                  theme: AppTheme.getLightTheme(),
                  themeMode:
                      appCubit.state.isDarkMode
                          ? ThemeMode.dark
                          : ThemeMode.light,
                  darkTheme: AppTheme.getDarkTheme(),
                  routerConfig: _appRouter.config(
                    navigatorObservers: () => [AppRouterObserver()],
                  ),
                  debugShowCheckedModeBanner: false,
                  locale: TranslationProvider.of(context).flutterLocale,
                  supportedLocales: AppLocaleUtils.supportedLocales,
                  localizationsDelegates: GlobalMaterialLocalizations.delegates,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
