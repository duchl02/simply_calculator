import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:simply_calculator/router/app_router.gr.dart';

@singleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.cupertino();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: CalcHistoryRoute.page),
    AutoRoute(page: CalculatorRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: LanguageRoute.page),
    AutoRoute(page: FeedbackRoute.page),
    AutoRoute(page: ThemeSettingsRoute.page),
    AutoRoute(page: UnitConverterRoute.page),
    AutoRoute(page: ToolsHubRoute.page),
    AutoRoute(page: CurrencyConverterRoute.page),
    AutoRoute(page: DiscountCalculatorRoute.page),
    AutoRoute(page: TipCalculatorRoute.page),
    AutoRoute(page: DateCalculatorRoute.page),
    AutoRoute(page: LoanCalculatorRoute.page),
    AutoRoute(page: GpaCalculatorRoute.page),
    AutoRoute(page: BmiCalculatorRoute.page),
    AutoRoute(page: AgeCalculatorRoute.page),
  ];
}
