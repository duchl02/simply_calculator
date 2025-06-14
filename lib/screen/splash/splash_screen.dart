import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/domain/repositories/app_repository.dart';
import 'package:simply_calculator/router/app_router.gr.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppCubit appCubit = getIt<AppCubit>();
  @override
  void initState() {
    super.initState();
    appCubit.initial();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isFirstOpenApp = getIt<AppRepository>().getFirstTimeOpenApp();
      if (isFirstOpenApp == null) {
        AutoRouter.of(context).replace(const OnboardingRoute());
        getIt<AppRepository>().setFirstTimeOpenApp(
          DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        AutoRouter.of(context).replace(const CalculatorRoute());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox());
  }
}
