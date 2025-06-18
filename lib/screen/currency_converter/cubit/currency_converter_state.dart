import 'package:equatable/equatable.dart';
import 'package:simply_calculator/domain/models/currency_model.dart';

class CurrencyConverterState extends Equatable {
  final List<CurrencyModel> currencies;
  final CurrencyModel fromCurrency;
  final CurrencyModel toCurrency;
  final String inputAmount;
  final double? convertedAmount;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const CurrencyConverterState({
    required this.currencies,
    required this.fromCurrency,
    required this.toCurrency,
    this.inputAmount = '1',
    this.convertedAmount,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  CurrencyConverterState copyWith({
    List<CurrencyModel>? currencies,
    CurrencyModel? fromCurrency,
    CurrencyModel? toCurrency,
    String? inputAmount,
    double? convertedAmount,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CurrencyConverterState(
      currencies: currencies ?? this.currencies,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      inputAmount: inputAmount ?? this.inputAmount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    currencies,
    fromCurrency,
    toCurrency,
    inputAmount,
    convertedAmount,
    isLoading,
    error,
    lastUpdated,
  ];
}
