import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';
import 'package:intl/intl.dart';

@RoutePage()
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1');
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _result = 0;
  bool _isLoading = false;
  
  // In a real app, you would fetch these from an API
  final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'GBP': 0.73,
    'JPY': 110.25,
    'CAD': 1.25,
    'AUD': 1.36,
    'CHF': 0.92,
    'CNY': 6.47,
  };
  
  final Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
  };
  
  final Map<String, String> _currencyFlags = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'JPY': '🇯🇵',
    'CAD': '🇨🇦',
    'AUD': '🇦🇺',
    'CHF': '🇨🇭',
    'CNY': '🇨🇳',
  };
  
  @override
  void initState() {
    super.initState();
    _calculateConversion();
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  void _calculateConversion() {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API request delay
    Future.delayed(const Duration(milliseconds: 300), () {
      double fromRate = _exchangeRates[_fromCurrency] ?? 1;
      double toRate = _exchangeRates[_toCurrency] ?? 1;
      
      setState(() {
        _result = amount * (toRate / fromRate);
        _isLoading = false;
      });
    });
  }
  
  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _calculateConversion();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppScaffold(
      title: t.currency_converter,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount input
            Card(
              margin: EdgeInsets.only(bottom: 16.h),
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.amount,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surface,
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      onChanged: (value) => _calculateConversion(),
                    ),
                  ],
                ),
              ),
            ),
            
            // From and To currency selection
            Row(
              children: [
                Expanded(
                  child: _buildCurrencySelector(
                    title: t.from,
                    value: _fromCurrency,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _fromCurrency = value);
                        _calculateConversion();
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: _swapCurrencies,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildCurrencySelector(
                    title: t.to,
                    value: _toCurrency,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _toCurrency = value);
                        _calculateConversion();
                      }
                    },
                  ),
                ),
              ],
            ),
            
            // Result display
            Card(
              margin: EdgeInsets.only(top: 24.h),
              elevation: 0,
              color: colorScheme.primaryContainer.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_currencyFlags[_fromCurrency] ?? ''} $_fromCurrency',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Icon(
                            Icons.arrow_forward,
                            color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                            size: 18.sp,
                          ),
                        ),
                        Text(
                          '${_currencyFlags[_toCurrency] ?? ''} $_toCurrency',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Text(
                        NumberFormat.currency(
                          symbol: _toCurrency,
                          decimalDigits: 2,
                        ).format(_result),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                      ),
                    SizedBox(height: 8.h),
                    Text(
                      '1 $_fromCurrency = ${NumberFormat.currency(symbol: _toCurrency, decimalDigits: 4).format(_exchangeRates[_toCurrency]! / _exchangeRates[_fromCurrency]!)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Currency list
            Padding(
              padding: EdgeInsets.only(top: 24.h, bottom: 8.h),
              child: Text(
                t.popular_currencies,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onBackground,
                    ),
              ),
            ),
            
            ...List.generate(
              _exchangeRates.length ~/ 2,
              (index) {
                final fromKey = _exchangeRates.keys.elementAt(index * 2);
                final toKey = _exchangeRates.keys.elementAt(index * 2 + 1);
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Expanded(child: _buildCurrencyRate(fromKey)),
                      SizedBox(width: 8.w),
                      Expanded(child: _buildCurrencyRate(toKey)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrencySelector({
    required String title,
    required String value,
    required void Function(String?) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down),
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surface,
                prefixText: '${_currencyFlags[value] ?? ''} ',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _exchangeRates.keys
                  .map((currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(
                          '${_currencyFlags[currency] ?? ''} $currency - ${_currencyNames[currency]}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrencyRate(String currency) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Text(
              _currencyFlags[currency] ?? '',
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: '',
                      decimalDigits: 2,
                    ).format(_exchangeRates[currency]! / _exchangeRates['USD']!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}