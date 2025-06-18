import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply_calculator/core/firebase/analytics/analytics_util.dart';
import 'package:simply_calculator/domain/models/currency_model.dart';
import 'package:simply_calculator/domain/repositories/currency_repository.dart';
import 'package:simply_calculator/screen/currency_converter/cubit/currency_converter_state.dart';

class CurrencyConverterCubit extends Cubit<CurrencyConverterState> {
  final CurrencyRepository _currencyRepository;

  CurrencyConverterCubit(this._currencyRepository)
    : super(
        CurrencyConverterState(
          currencies: _currencyRepository.getCurrencies(),
          fromCurrency: _currencyRepository.getCurrencies().first,
          toCurrency: _currencyRepository.getCurrencies()[1],
        ),
      ) {
    // Initial conversion
    convertCurrency();
  }

  void updateFromCurrency(CurrencyModel currency) {
    AnalyticsUtil.logEvent(EventKeyConst.currencyFromChanged);

    if (currency.code == state.toCurrency.code) {
      // If selecting same currency, swap them
      emit(
        state.copyWith(fromCurrency: currency, toCurrency: state.fromCurrency),
      );
    } else {
      emit(state.copyWith(fromCurrency: currency));
    }
    convertCurrency();
  }

  void updateToCurrency(CurrencyModel currency) {
    AnalyticsUtil.logEvent(EventKeyConst.currencyToChanged);

    if (currency.code == state.fromCurrency.code) {
      // If selecting same currency, swap them
      emit(
        state.copyWith(toCurrency: currency, fromCurrency: state.toCurrency),
      );
    } else {
      emit(state.copyWith(toCurrency: currency));
    }
    convertCurrency();
  }

  void updateInputAmount(String amount) {
    emit(state.copyWith(inputAmount: amount));
    convertCurrency();
  }

  void swapCurrencies() {
    AnalyticsUtil.logEvent(EventKeyConst.currencySwapButtonPressed);

    emit(
      state.copyWith(
        fromCurrency: state.toCurrency,
        toCurrency: state.fromCurrency,
      ),
    );
    convertCurrency();
  }

  Future<void> convertCurrency() async {
    final amount = double.tryParse(state.inputAmount);

    if (amount == null || amount <= 0) {
      emit(
        state.copyWith(
          convertedAmount: 0.0,
          error: 'Please enter a valid amount',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final rate = await _currencyRepository.getExchangeRate(
        state.fromCurrency.code,
        state.toCurrency.code,
      );

      final convertedAmount = amount * rate;

      emit(
        state.copyWith(
          convertedAmount: convertedAmount,
          isLoading: false,
          lastUpdated: DateTime.now(),
        ),
      );

      // Log successful conversion
      AnalyticsUtil.logEvent(EventKeyConst.currencyConverted);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to convert currency. Please try again later.',
        ),
      );

      // Log error
      AnalyticsUtil.logEvent(EventKeyConst.currencyConversionError);
    }
  }

  void refreshRates() {
    AnalyticsUtil.logEvent(EventKeyConst.currencyRefreshPressed);
    convertCurrency();
  }
}
