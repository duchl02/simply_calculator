import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/core/firebase/analytics/analytics_util.dart';
import 'package:simply_calculator/core/managers/feature_tips_manager.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/calculator/history/cubit/calc_history_cubit.dart';
import 'package:simply_calculator/screen/calculator/widgets/empty_history_widget.dart';
import 'package:simply_calculator/screen/calculator/widgets/group_calc_history_widget.dart';
import 'package:simply_calculator/screen/widgets/button/app_filled_button.dart';
import 'package:simply_calculator/screen/widgets/dialog/app_dialog.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';

@RoutePage()
class CalcHistoryScreen extends StatefulWidget {
  const CalcHistoryScreen({super.key});

  @override
  State<CalcHistoryScreen> createState() => _CalcHistoryScreenState();
}

class _CalcHistoryScreenState extends State<CalcHistoryScreen> {
  late final CalcHistoryCubit _cubit;
  @override
  void initState() {
    _cubit = CalcHistoryCubit();
    FeatureTipsManager.markFeatureAsUsed(CalcHistoryRoute.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit..loadHistory(),
      child: BlocBuilder<CalcHistoryCubit, CalcHistoryState>(
        builder: (context, state) {
          return AppScaffold(
            title: t.calculator_history,
            body: Builder(
              builder: (_) {
                if (state.historyItem.isEmpty) {
                  return const EmptyHistoryWidget();
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          GroupCalcHistoryWidget(
                            groupedHistory: state.history,
                            onItemTap: (item) {
                              if (state.isInSelectionMode) {
                                _cubit.toggleSelectItem(item);
                                // Log select/deselect item event
                                AnalyticsUtil.logEvent(
                                  EventKeyConst.historyItemToggled,
                                );
                              } else {
                                // Log item used from history
                                AnalyticsUtil.logEvent(
                                  EventKeyConst.historyItemUsed,
                                );
                                AutoRouter.of(context).pop(item);
                              }
                            },
                            onItemLongPress: (item) {
                              // Log entering selection mode via long press
                              AnalyticsUtil.logEvent(
                                EventKeyConst.historySelectionModeEntered,
                              );
                              _cubit.toggleSelectItem(item);
                            },
                            selectedItems: state.selectedItem,
                          ),
                        ],
                      ),
                    ),
                    if (state.historyItem.isNotEmpty)
                      SafeArea(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AppFilledButton(
                                  onTap: () {
                                    if (state.isInSelectionMode) {
                                      // Log exit selection mode
                                      AnalyticsUtil.logEvent(
                                        EventKeyConst
                                            .historySelectionModeExited,
                                      );
                                      _cubit.cancelSelection();
                                    } else {
                                      // Log enter selection mode
                                      AnalyticsUtil.logEvent(
                                        EventKeyConst
                                            .historySelectionModeEntered,
                                      );
                                      _cubit.toggleSelectItem(
                                        state.historyItem.first,
                                      );
                                    }
                                  },
                                  title:
                                      state.isInSelectionMode ? t.done : t.edit,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.1),
                                  textColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: AppFilledButton(
                                  onTap: () {
                                    if (state.isInSelectionMode) {
                                      // Log delete selected items
                                      AnalyticsUtil.logEvent(
                                        EventKeyConst.historyItemsDeleted,
                                      );
                                      _cubit.deleteMultipleHistoryItems();
                                    } else {
                                      // Log show clear history dialog
                                      AnalyticsUtil.logEvent(
                                        EventKeyConst.historyClearDialogShown,
                                      );
                                      AppDialog.show(
                                        context: context,
                                        title: t.clear_history,
                                        content: t.clear_history_confirm,
                                        onRightButton: () {
                                          // Log clear all history
                                          AnalyticsUtil.logEvent(
                                            EventKeyConst.historyCleared,
                                          );
                                          _cubit.clearHistory();
                                          AutoRouter.of(context).pop();
                                        },
                                        onLeftButton: () {
                                          // Log cancel clear history
                                          AnalyticsUtil.logEvent(
                                            EventKeyConst.historyClearCanceled,
                                          );
                                          AutoRouter.of(context).pop();
                                        },
                                      );
                                    }
                                  },
                                  title: t.delete,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            backgroundColor: context.colorScheme.surface,
          );
        },
      ),
    );
  }
}
