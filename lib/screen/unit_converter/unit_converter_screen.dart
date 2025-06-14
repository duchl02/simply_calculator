import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/core/managers/feature_tips_manager.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/domain/entities/favorite_calc_item.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/unit_converter/cubit/unit_converter_cubit.dart';
import 'package:simply_calculator/screen/unit_converter/models/unit_category.dart';
import 'package:simply_calculator/screen/unit_converter/models/unit_item.dart';
import 'package:simply_calculator/screen/widgets/button/favorite_button.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';
import 'package:simply_calculator/screen/unit_converter/utils/unit_conversion_util.dart';

@RoutePage()
class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final TextEditingController _inputController = TextEditingController(
    text: '1',
  );
  late ScrollController _categoriesScrollController;

  @override
  void initState() {
    super.initState();
    _categoriesScrollController = ScrollController();
    FeatureTipsManager.markFeatureAsUsed(UnitConverterRoute.name);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _categoriesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UnitConverterCubit(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<UnitConverterCubit, UnitConverterState>(
            listener: (context, state) {
              if (state.inputValue.isEmpty) {
                _inputController.text = '';
              } else if (_inputController.text != state.inputValue) {
                _inputController.text = state.inputValue;
              }
            },
            builder: (context, state) {
              return AppScaffold(
                title: t.unit_converter,
                body: Column(
                  children: [
                    // Categories horizontal list
                    _buildCategoriesList(context, state),

                    // Main conversion area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Current category name
                            Text(
                              state.currentCategory.displayName,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // From Unit Section
                            _buildFromUnitSection(context, state),

                            // Swap button
                            _buildSwapButton(context),

                            // To Unit Section
                            _buildToUnitSection(context, state),

                            // Results card
                            _buildResultsCard(context, state),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, UnitConverterState state) {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: ListView.builder(
        controller: _categoriesScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        itemCount: UnitCategory.values.length,
        itemBuilder: (context, index) {
          final category = UnitCategory.values[index];
          final isSelected = category == state.currentCategory;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: _buildCategoryItem(context, category, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    UnitCategory category,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        context.read<UnitConverterCubit>().changeCategory(category);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76.w,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 1),
                    ),
                  ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 28.sp,
            ),
            SizedBox(height: 6.h),
            Text(
              category.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFromUnitSection(BuildContext context, UnitConverterState state) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.from,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                _buildUnitDropdown(
                  context,
                  state.fromUnit,
                  state.currentCategory.units,
                  (unit) =>
                      context.read<UnitConverterCubit>().changeFromUnit(unit),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    _inputController.clear();
                    context.read<UnitConverterCubit>().updateInputValue('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                context.read<UnitConverterCubit>().updateInputValue(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapButton(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            context.read<UnitConverterCubit>().swapUnits();
          },
          icon: Icon(
            Icons.swap_vert_rounded,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            size: 28.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildToUnitSection(BuildContext context, UnitConverterState state) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.to,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                _buildUnitDropdown(
                  context,
                  state.toUnit,
                  state.currentCategory.units,
                  (unit) =>
                      context.read<UnitConverterCubit>().changeToUnit(unit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitDropdown(
    BuildContext context,
    UnitItem selectedUnit,
    List<UnitItem> units,
    Function(UnitItem) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButton<UnitItem>(
        value: selectedUnit,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        elevation: 4,
        underline: const SizedBox(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        items:
            units.map((UnitItem unit) {
              return DropdownMenuItem<UnitItem>(
                value: unit,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(unit.shortName),
                    SizedBox(width: 8.w),
                    Text(
                      "(${unit.name})",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (UnitItem? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context, UnitConverterState state) {
    if (state.inputValue.isEmpty) {
      return const SizedBox.shrink();
    }

    double? inputValue = double.tryParse(state.inputValue);
    if (inputValue == null) {
      return const SizedBox.shrink();
    }

    // Kiểm tra giá trị hợp lệ
    if (!UnitConversionUtil.isValidInput(
      inputValue,
      state.currentCategory,
      state.fromUnit,
    )) {
      return Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.errorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        margin: EdgeInsets.only(top: 24.h),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 32.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                t.input_value_error,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              if (state.currentCategory == UnitCategory.temperature &&
                  state.fromUnit.shortName == 'K' &&
                  inputValue < 0)
                Text(
                  t.kelvin_negative_error,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      );
    }

    // Tính kết quả chuyển đổi
    final double result = UnitConversionUtil.convert(
      value: inputValue,
      fromUnit: state.fromUnit,
      toUnit: state.toUnit,
      category: state.currentCategory,
    );

    // Định dạng kết quả
    final formattedResult = UnitConversionUtil.formatResult(
      result,
      state.currentCategory,
    );

    // Lấy công thức chuyển đổi
    final conversionFormula = UnitConversionUtil.getConversionFormula(
      state.currentCategory,
      state.fromUnit,
      state.toUnit,
    );

    // Phần UI hiển thị kết quả
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      margin: EdgeInsets.only(top: 24.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              t.result,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              formattedResult,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              state.toUnit.name,
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            // Hiển thị phép tính chuyển đổi
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${state.inputValue} ${state.fromUnit.shortName} = ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '$formattedResult ${state.toUnit.shortName}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Hiển thị công thức chuyển đổi
                  Text(
                    conversionFormula,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Gợi ý chuyển đổi phổ biến
            _buildCommonConversions(context, state, inputValue),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: () {
                final textToCopy =
                    '${state.inputValue} ${state.fromUnit.shortName} = $formattedResult ${state.toUnit.shortName}';
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
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thêm phương thức hiển thị các chuyển đổi phổ biến
  Widget _buildCommonConversions(
    BuildContext context,
    UnitConverterState state,
    double inputValue,
  ) {
    // Lấy các giá trị gợi ý cho danh mục hiện tại
    final suggestedValues = UnitConversionUtil.getSuggestedValues(
      state.currentCategory,
      state.fromUnit,
    );

    // Nếu giá trị nhập vào là một trong các giá trị gợi ý, không hiển thị phần này
    if (suggestedValues.contains(inputValue)) {
      return const SizedBox.shrink();
    }

    // Chỉ hiển thị một số lượng giới hạn gợi ý để không làm màn hình quá dài
    final displayValues = suggestedValues.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            t.common_conversions,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children:
              displayValues.map((value) {
                // Tính kết quả chuyển đổi cho mỗi giá trị gợi ý
                final result = UnitConversionUtil.convert(
                  value: value,
                  fromUnit: state.fromUnit,
                  toUnit: state.toUnit,
                  category: state.currentCategory,
                );

                final formattedResult = UnitConversionUtil.formatResult(
                  result,
                  state.currentCategory,
                );

                return InkWell(
                  onTap: () {
                    // Khi người dùng nhấp vào, cập nhật giá trị đầu vào
                    context.read<UnitConverterCubit>().updateInputValue(
                      value.toString(),
                    );
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '$value ${state.fromUnit.shortName} = $formattedResult ${state.toUnit.shortName}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
