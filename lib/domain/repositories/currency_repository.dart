import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:simply_calculator/core/firebase/analytics/analytics_util.dart';
import 'package:simply_calculator/domain/models/currency_model.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/widgets/snack_bar/app_snackbar.dart';

@singleton
class CurrencyRepository {
  static const String _baseUrl = 'https://api.frankfurter.app';

  final List<CurrencyModel> _currencies = [
    const CurrencyModel(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      flag: '🇺🇸',
    ),
    const CurrencyModel(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    const CurrencyModel(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      flag: '🇬🇧',
    ),
    const CurrencyModel(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      flag: '🇯🇵',
    ),
    const CurrencyModel(
      code: 'CNY',
      name: 'Chinese Yuan',
      symbol: '¥',
      flag: '🇨🇳',
    ),
    const CurrencyModel(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      flag: '🇦🇺',
    ),
    const CurrencyModel(
      code: 'BGN',
      name: 'Bulgarian Lev',
      symbol: 'лв',
      flag: '🇧🇬',
    ),
    const CurrencyModel(
      code: 'BRL',
      name: 'Brazilian Real',
      symbol: 'R\$',
      flag: '🇧🇷',
    ),
    const CurrencyModel(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      flag: '🇨🇦',
    ),
    const CurrencyModel(
      code: 'CHF',
      name: 'Swiss Franc',
      symbol: 'Fr',
      flag: '🇨🇭',
    ),
    const CurrencyModel(
      code: 'CZK',
      name: 'Czech Koruna',
      symbol: 'Kč',
      flag: '🇨🇿',
    ),
    const CurrencyModel(
      code: 'DKK',
      name: 'Danish Krone',
      symbol: 'kr',
      flag: '🇩🇰',
    ),
    const CurrencyModel(
      code: 'HKD',
      name: 'Hong Kong Dollar',
      symbol: 'HK\$',
      flag: '🇭🇰',
    ),
    const CurrencyModel(
      code: 'HUF',
      name: 'Hungarian Forint',
      symbol: 'Ft',
      flag: '🇭🇺',
    ),
    const CurrencyModel(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      flag: '🇮🇩',
    ),
    const CurrencyModel(
      code: 'ILS',
      name: 'Israeli Shekel',
      symbol: '₪',
      flag: '🇮🇱',
    ),
    const CurrencyModel(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      flag: '🇮🇳',
    ),
    const CurrencyModel(
      code: 'ISK',
      name: 'Icelandic Krona',
      symbol: 'kr',
      flag: '🇮🇸',
    ),
    const CurrencyModel(
      code: 'KRW',
      name: 'South Korean Won',
      symbol: '₩',
      flag: '🇰🇷',
    ),
    const CurrencyModel(
      code: 'MXN',
      name: 'Mexican Peso',
      symbol: 'Mex\$',
      flag: '🇲🇽',
    ),
    const CurrencyModel(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      flag: '🇲🇾',
    ),
    const CurrencyModel(
      code: 'NOK',
      name: 'Norwegian Krone',
      symbol: 'kr',
      flag: '🇳🇴',
    ),
    const CurrencyModel(
      code: 'NZD',
      name: 'New Zealand Dollar',
      symbol: 'NZ\$',
      flag: '🇳🇿',
    ),
    const CurrencyModel(
      code: 'PHP',
      name: 'Philippine Peso',
      symbol: '₱',
      flag: '🇵🇭',
    ),
    const CurrencyModel(
      code: 'PLN',
      name: 'Polish Złoty',
      symbol: 'zł',
      flag: '🇵🇱',
    ),
    const CurrencyModel(
      code: 'RON',
      name: 'Romanian Leu',
      symbol: 'lei',
      flag: '🇷🇴',
    ),
    const CurrencyModel(
      code: 'SEK',
      name: 'Swedish Krona',
      symbol: 'kr',
      flag: '🇸🇪',
    ),
    const CurrencyModel(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      flag: '🇸🇬',
    ),
    const CurrencyModel(
      code: 'THB',
      name: 'Thai Baht',
      symbol: '฿',
      flag: '🇹🇭',
    ),
    const CurrencyModel(
      code: 'TRY',
      name: 'Turkish Lira',
      symbol: '₺',
      flag: '🇹🇷',
    ),
    const CurrencyModel(
      code: 'ZAR',
      name: 'South African Rand',
      symbol: 'R',
      flag: '🇿🇦',
    ),
    const CurrencyModel(
      code: 'VND',
      name: 'Vietnamese Dong',
      symbol: '₫',
      flag: '🇻🇳',
    ),
  ];

  List<CurrencyModel> getCurrencies() {
    return _currencies;
  }

  Future<double> getExchangeRate(String from, String to) async {
    AnalyticsUtil.logEvent('get_exchange_rate', {'from': from, 'to': to});
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest?from=$from&to=$to'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['rates'][to];
      } else {
        AnalyticsUtil.logEvent('get_exchange_rate_error', {
          'from': from,
          'to': to,
          'status_code': response.statusCode,
        });
        AppSnackbar.showError(message: t.failed_to_load_exchange_rate);
        throw Exception('Failed to load exchange rate');
      }
    } catch (e) {
      // Fallback to a cached rate or estimation if API fails
      return _getFallbackRate(from, to);
    }
  }

  // Fallback rates for offline use or API failure
  double _getFallbackRate(String from, String to) {
    // Updated rates based on the provided data
    final Map<String, double> usdRates = {
      'USD': 1.1574, // Using value from image
      'EUR': 1.0, // Base currency
      'GBP': 0.8523,
      'JPY': 166.89,
      'CNY': 8.3102,
      'AUD': 1.7732,
      'BGN': 1.9558,
      'BRL': 6.4033,
      'CAD': 1.5701,
      'CHF': 0.9393,
      'CZK': 24.782,
      'DKK': 7.4581,
      'HKD': 9.0853,
      'HUF': 401.53,
      'IDR': 18851,
      'ILS': 4.0759,
      'INR': 99.58,
      'ISK': 143.8,
      'KRW': 1573.46,
      'MXN': 21.886,
      'MYR': 4.908,
      'NOK': 11.467,
      'NZD': 1.9113,
      'PHP': 65.215,
      'PLN': 4.2643,
      'RON': 5.025,
      'SEK': 10.9615,
      'SGD': 1.4810,
      'THB': 37.598,
      'TRY': 45.597,
      'ZAR': 20.58,
      'VND': 30167, // Approximate EUR:VND rate
    };

    // Same conversion logic as before
    if (from == to) return 1.0;

    // Adjust the logic since these rates appear to be against EUR, not USD
    if (from == 'EUR') {
      return usdRates[to] ?? 1.0;
    } else if (to == 'EUR') {
      return 1.0 / (usdRates[from] ?? 1.0);
    } else {
      // from -> EUR -> to
      return (1.0 / (usdRates[from] ?? 1.0)) * (usdRates[to] ?? 1.0);
    }
  }
}
