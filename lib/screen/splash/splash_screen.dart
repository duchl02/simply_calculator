import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/di/di.dart';
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
      Future.delayed(const Duration(seconds: 0), () {
        context.router.replace(const HomeRoute());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Splash Screen')));
  }
}
