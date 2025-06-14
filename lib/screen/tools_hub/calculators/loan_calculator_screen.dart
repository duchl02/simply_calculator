import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/domain/entities/favorite_calc_item.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/button/favorite_button.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

@RoutePage()
class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  // Input controllers
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanTermYearsController =
      TextEditingController();

  // Calculation results
  double _monthlyPayment = 0.0;
  double _totalPayment = 0.0;
  double _totalInterest = 0.0;

  // Chart data
  List<PieChartSectionData> _pieChartData = [];

  // Payment schedule
  List<PaymentScheduleItem> _paymentSchedule = [];
  bool _showFullSchedule = false;

  // Loan type selection
  String _selectedLoanType = 'mortgage'; // mortgage, auto, personal, student

  @override
  void initState() {
    super.initState();

    // Set default values
    _loanAmountController.text = '250000';
    _interestRateController.text = '4.5';
    _loanTermYearsController.text = '30';

    // Add listeners
    _loanAmountController.addListener(_calculateLoan);
    _interestRateController.addListener(_calculateLoan);
    _loanTermYearsController.addListener(_calculateLoan);

    // Initial calculation
    _calculateLoan();
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _loanTermYearsController.dispose();
    super.dispose();
  }

  void _calculateLoan() {
    final loanAmountText = _loanAmountController.text.trim().replaceAll(
      ',',
      '',
    );
    final interestRateText = _interestRateController.text.trim();
    final loanTermYearsText = _loanTermYearsController.text.trim();

    if (loanAmountText.isEmpty ||
        interestRateText.isEmpty ||
        loanTermYearsText.isEmpty) {
      _resetCalculations();
      return;
    }

    try {
      final loanAmount = double.parse(loanAmountText);
      final annualInterestRate = double.parse(interestRateText);
      final loanTermYears = int.parse(loanTermYearsText);

      if (loanAmount <= 0 || annualInterestRate <= 0 || loanTermYears <= 0) {
        _resetCalculations();
        return;
      }

      // Monthly interest rate (annual rate divided by 12 months and converted to decimal)
      final monthlyRate = annualInterestRate / 100 / 12;

      // Total number of payments (years * 12 months)
      final numberOfPayments = loanTermYears * 12;

      // Calculate monthly payment using the loan amortization formula
      // M = P[r(1+r)^n]/[(1+r)^n-1]
      // where:
      // M = monthly payment
      // P = principal (loan amount)
      // r = monthly interest rate
      // n = number of payments
      final monthlyPayment =
          loanAmount *
          (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
          (pow(1 + monthlyRate, numberOfPayments) - 1);

      final totalPayment = monthlyPayment * numberOfPayments;
      final totalInterest = totalPayment - loanAmount;

      setState(() {
        _monthlyPayment = monthlyPayment;
        _totalPayment = totalPayment;
        _totalInterest = totalInterest;

        // Update pie chart data
        _pieChartData = [
          PieChartSectionData(
            value: loanAmount,
            title: t.principal,
            color: Colors.blue,
            radius: 50.r,
            titleStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: totalInterest,
            title: t.interest,
            color: Colors.red,
            radius: 60.r,
            titleStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ];

        // Generate amortization schedule
        _generateAmortizationSchedule(
          loanAmount,
          monthlyRate,
          monthlyPayment,
          numberOfPayments,
        );
      });
    } catch (e) {
      _resetCalculations();
    }
  }

  void _resetCalculations() {
    setState(() {
      _monthlyPayment = 0.0;
      _totalPayment = 0.0;
      _totalInterest = 0.0;
      _pieChartData = [];
      _paymentSchedule = [];
    });
  }

  void _generateAmortizationSchedule(
    double loanAmount,
    double monthlyRate,
    double monthlyPayment,
    int totalPayments,
  ) {
    double remainingBalance = loanAmount;
    List<PaymentScheduleItem> schedule = [];

    for (
      int paymentNumber = 1;
      paymentNumber <= totalPayments;
      paymentNumber++
    ) {
      // Calculate interest for this period
      final interestPayment = remainingBalance * monthlyRate;

      // Calculate principal for this period
      final principalPayment = monthlyPayment - interestPayment;

      // Update remaining balance
      remainingBalance = remainingBalance - principalPayment;

      // Ensure the final payment doesn't result in negative balance due to floating point precision
      if (paymentNumber == totalPayments) {
        remainingBalance = 0;
      }

      // Add to schedule
      schedule.add(
        PaymentScheduleItem(
          paymentNumber: paymentNumber,
          principalPayment: principalPayment,
          interestPayment: interestPayment,
          remainingBalance: remainingBalance < 0 ? 0 : remainingBalance,
        ),
      );
    }

    _paymentSchedule = schedule;
  }

  void _updateLoanType(String loanType) {
    setState(() {
      _selectedLoanType = loanType;

      // Set default values based on loan type
      switch (loanType) {
        case 'mortgage':
          _loanAmountController.text = '250000';
          _interestRateController.text = '4.5';
          _loanTermYearsController.text = '30';
          break;
        case 'auto':
          _loanAmountController.text = '35000';
          _interestRateController.text = '5.5';
          _loanTermYearsController.text = '5';
          break;
        case 'personal':
          _loanAmountController.text = '15000';
          _interestRateController.text = '9.5';
          _loanTermYearsController.text = '3';
          break;
        case 'student':
          _loanAmountController.text = '50000';
          _interestRateController.text = '4.99';
          _loanTermYearsController.text = '10';
          break;
      }

      _calculateLoan();
    });
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: t.loan_calculator,
      actions: [
        FavoriteButton(
          calculatorItem: FavoriteCalcItem(
            title: t.loan_calculator,
            routeName: LoanCalculatorRoute.name,
            icon: Icons.account_balance,
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Loan Type Selection
            Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.loan_type,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildLoanTypeButton(
                            'mortgage',
                            Icons.home,
                            t.mortgage,
                          ),
                          SizedBox(width: 12.w),
                          _buildLoanTypeButton(
                            'auto',
                            Icons.directions_car,
                            t.auto_loan,
                          ),
                          SizedBox(width: 12.w),
                          _buildLoanTypeButton(
                            'personal',
                            Icons.account_balance_wallet,
                            t.personal_loan,
                          ),
                          SizedBox(width: 12.w),
                          _buildLoanTypeButton(
                            'student',
                            Icons.school,
                            t.student_loan,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Input Card
            Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Loan Amount
                    Text(
                      t.loan_amount,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _loanAmountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.attach_money,
                            color: colorScheme.primary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                        _ThousandsSeparatorInputFormatter(),
                      ],
                    ),

                    // Divider
                    Divider(height: 32.h),

                    // Interest Rate
                    Text(
                      t.annual_interest_rate,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _interestRateController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.percent,
                            color: colorScheme.primary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 16.w,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                    ),

                    // Quick interest rate buttons
                    SizedBox(height: 8.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickRateButton('3.5'),
                          SizedBox(width: 8.w),
                          _buildQuickRateButton('4.0'),
                          SizedBox(width: 8.w),
                          _buildQuickRateButton('4.5'),
                          SizedBox(width: 8.w),
                          _buildQuickRateButton('5.0'),
                          SizedBox(width: 8.w),
                          _buildQuickRateButton('6.0'),
                        ],
                      ),
                    ),

                    // Divider
                    Divider(height: 32.h),

                    // Loan Term in Years
                    Text(
                      t.loan_term_years,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _loanTermYearsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            t.years,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 16.w,
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    // Quick term buttons
                    SizedBox(height: 8.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickTermButton('15'),
                          SizedBox(width: 8.w),
                          _buildQuickTermButton('20'),
                          SizedBox(width: 8.w),
                          _buildQuickTermButton('25'),
                          SizedBox(width: 8.w),
                          _buildQuickTermButton('30'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Results Card
            if (_monthlyPayment > 0)
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.payment_details,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 24.h),

                      // Monthly Payment
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              t.monthly_payment,
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _formatCurrency(_monthlyPayment),
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Total Payment and Interest
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.08,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          children: [
                            // Total Payment
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.total_payment,
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer
                                        .withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(_totalPayment),
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8.h),

                            // Total Interest
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.total_interest,
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer
                                        .withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(_totalInterest),
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8.h),

                            // Principal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.principal_amount,
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer
                                        .withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(
                                    double.parse(
                                      _loanAmountController.text.replaceAll(
                                        ',',
                                        '',
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // Loan Term
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.loan_term,
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer
                                        .withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${_loanTermYearsController.text} ${t.years} (${int.parse(_loanTermYearsController.text) * 12} ${t.payments})',
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Chart
                      if (_pieChartData.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        Container(
                          height: 200.h,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimaryContainer.withOpacity(
                              0.08,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sections: _pieChartData,
                                    centerSpaceRadius: 40.r,
                                    sectionsSpace: 0,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLegendItem(t.principal, Colors.blue),
                                  SizedBox(height: 16.h),
                                  _buildLegendItem(t.interest, Colors.red),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Copy button
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: () {
                          final result = '''
${t.loan_amount}: ${_formatCurrency(double.parse(_loanAmountController.text.replaceAll(',', '')))}
${t.annual_interest_rate}: ${_interestRateController.text}%
${t.loan_term_years}: ${_loanTermYearsController.text} ${t.years}
${t.monthly_payment}: ${_formatCurrency(_monthlyPayment)}
${t.total_payment}: ${_formatCurrency(_totalPayment)}
${t.total_interest}: ${_formatCurrency(_totalInterest)}
''';
                          Clipboard.setData(ClipboardData(text: result));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t.copied_to_clipboard),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(Icons.copy, size: 18.sp),
                        label: Text(t.copy_summary),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onPrimaryContainer,
                          side: BorderSide(
                            color: colorScheme.onPrimaryContainer.withOpacity(
                              0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Amortization Schedule
            if (_paymentSchedule.isNotEmpty) ...[
              SizedBox(height: 24.h),
              Card(
                elevation: 0,
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t.amortization_schedule,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showFullSchedule = !_showFullSchedule;
                              });
                            },
                            child: Text(
                              _showFullSchedule ? t.show_less : t.show_more,
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // Schedule header
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.2,
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                t.payment,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                t.principal,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                t.interest,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                t.balance,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Schedule rows
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            _showFullSchedule
                                ? _paymentSchedule.length
                                : min(12, _paymentSchedule.length),
                        itemBuilder: (context, index) {
                          final item = _paymentSchedule[index];
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: colorScheme.onSurfaceVariant
                                      .withOpacity(0.1),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${item.paymentNumber}',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatCurrency(item.principalPayment),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatCurrency(item.interestPayment),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatCurrency(item.remainingBalance),
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      if (!_showFullSchedule &&
                          _paymentSchedule.length > 12) ...[
                        SizedBox(height: 16.h),
                        Center(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showFullSchedule = true;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 8.h,
                              ),
                            ),
                            child: Text(t.view_full_schedule),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanTypeButton(String type, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedLoanType == type;

    return InkWell(
      onTap: () => _updateLoanType(type),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRateButton(String rate) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _interestRateController.text == rate;

    return OutlinedButton(
      onPressed: () {
        _interestRateController.text = rate;
      },
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isSelected ? colorScheme.onPrimary : colorScheme.primary,
        backgroundColor: isSelected ? colorScheme.primary : null,
        side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: Text('$rate%'),
    );
  }

  Widget _buildQuickTermButton(String years) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _loanTermYearsController.text == years;

    return OutlinedButton(
      onPressed: () {
        _loanTermYearsController.text = years;
      },
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isSelected ? colorScheme.onPrimary : colorScheme.primary,
        backgroundColor: isSelected ? colorScheme.primary : null,
        side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: Text('$years ${t.years}'),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimaryContainer.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Custom formatter for thousands separator
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only process if the user has done something
    if (oldValue.text.length == newValue.text.length) {
      return newValue;
    }

    // Handle backspace/delete
    if (oldValue.text.length > newValue.text.length) {
      return newValue;
    }

    final regExp = RegExp(r'[^\d]');
    final onlyNumbers = newValue.text.replaceAll(regExp, '');

    final formatted = onlyNumbers.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Payment schedule item model
class PaymentScheduleItem {
  final int paymentNumber;
  final double principalPayment;
  final double interestPayment;
  final double remainingBalance;

  PaymentScheduleItem({
    required this.paymentNumber,
    required this.principalPayment,
    required this.interestPayment,
    required this.remainingBalance,
  });
}
