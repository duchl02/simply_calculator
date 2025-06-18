import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:simply_calculator/core/firebase/analytics/analytics_util.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/domain/models/currency_model.dart';
import 'package:simply_calculator/domain/repositories/currency_repository.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/currency_converter/cubit/currency_converter_cubit.dart';
import 'package:simply_calculator/screen/currency_converter/cubit/currency_converter_state.dart';
import 'package:simply_calculator/screen/currency_converter/widgets/searchable_currency_dropdown.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';

@RoutePage()
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController(
    text: '1',
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CurrencyConverterCubit(getIt<CurrencyRepository>()),
      child: Builder(
        builder: (context) {
          return BlocConsumer<CurrencyConverterCubit, CurrencyConverterState>(
            listener: (context, state) {
              if (state.inputAmount != _amountController.text) {
                _amountController.text = state.inputAmount;
              }
            },
            builder: (context, state) {
              return AppScaffold(
                title: t.currency_converter,
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount input
                      _buildAmountInput(context, state),

                      SizedBox(height: 24.h),

                      // From currency selector
                      Text(
                        t.from,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      _buildCurrencySelector(
                        context,
                        state.currencies,
                        state.fromCurrency,
                        (currency) => context
                            .read<CurrencyConverterCubit>()
                            .updateFromCurrency(currency),
                      ),

                      SizedBox(height: 16.h),

                      // Swap button
                      Center(
                        child: IconButton(
                          onPressed: () {
                            context
                                .read<CurrencyConverterCubit>()
                                .swapCurrencies();
                          },
                          icon: Icon(
                            Icons.swap_vert_rounded,
                            size: 32.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.5),
                            padding: EdgeInsets.all(12.w),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // To currency selector
                      Text(
                        t.to,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      _buildCurrencySelector(
                        context,
                        state.currencies,
                        state.toCurrency,
                        (currency) => context
                            .read<CurrencyConverterCubit>()
                            .updateToCurrency(currency),
                      ),

                      SizedBox(height: 32.h),

                      // Result card
                      _buildResultCard(context, state),

                      SizedBox(height: 16.h),

                      // Last updated info
                      if (state.lastUpdated != null)
                        Center(
                          child: Text(
                            '${t.last_updated}: ${_formatUpdateTime(state.lastUpdated!)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                      SizedBox(height: 16.h),

                      // Refresh button
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            context
                                .read<CurrencyConverterCubit>()
                                .refreshRates();
                          },
                          icon: Icon(Icons.refresh, size: 18.sp),
                          label: Text(t.refresh_rates),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // API attribution
                      Center(
                        child: Text(
                          'Powered by Frankfurter API',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context, CurrencyConverterState state) {
    return TextField(
      controller: _amountController,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: t.amount,
        hintText: '1.00',
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            state.fromCurrency.symbol,
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            AnalyticsUtil.logEvent(EventKeyConst.currencyInputCleared);
            _amountController.clear();
            context.read<CurrencyConverterCubit>().updateInputAmount('');
            _focusNode.requestFocus();
          },
        ),
      ),
      onChanged: (value) {
        context.read<CurrencyConverterCubit>().updateInputAmount(value);
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
    );
  }

  Widget _buildCurrencySelector(
    BuildContext context,
    List<CurrencyModel> currencies,
    CurrencyModel selectedCurrency,
    void Function(CurrencyModel) onChanged,
  ) {
    return SearchableCurrencyDropdown(
      currencies: currencies,
      selectedCurrency: selectedCurrency,
      onChanged: onChanged,
    );
  }

  Widget _buildResultCard(BuildContext context, CurrencyConverterState state) {
    final inputAmount = double.tryParse(state.inputAmount) ?? 0.0;
    final amountString = _formatCurrency(
      inputAmount,
      state.fromCurrency.symbol,
    );

    final convertedAmount = state.convertedAmount ?? 0.0;
    final resultString = _formatCurrency(
      convertedAmount,
      state.toCurrency.symbol,
    );

    final rate = inputAmount > 0 ? (convertedAmount / inputAmount) : 0.0;
    final rateString = rate.toStringAsFixed(4);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result
          if (state.isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.error != null)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  state.error!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // From amount
                Text(
                  amountString,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 4.h),

                // Result
                Text(
                  resultString,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(height: 16.h),

                // Exchange rate
                Text(
                  '1 ${state.fromCurrency.code} = $rateString ${state.toCurrency.code}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

          SizedBox(height: 16.h),

          // Copy button
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                AnalyticsUtil.logEvent(EventKeyConst.currencyResultCopied);

                final textToCopy = '$amountString = $resultString';
                Clipboard.setData(ClipboardData(text: textToCopy));

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.copied_to_clipboard),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(Icons.copy, size: 18.sp),
              label: Text(t.copy_result),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount, String symbol) {
    return '$symbol ${NumberFormat.currency(symbol: '').format(amount)}';
  }

  String _formatUpdateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }
}
