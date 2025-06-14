import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/domain/entities/favorite_calc_item.dart';
import 'package:simply_calculator/screen/widgets/snack_bar/app_snackbar.dart';

class FavoriteButton extends StatelessWidget {
  final FavoriteCalcItem calculatorItem;

  const FavoriteButton({required this.calculatorItem, super.key});

  @override
  Widget build(BuildContext context) {
    final appCubit = getIt<AppCubit>();

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final isFavorite = appCubit.isFavorite(calculatorItem.routeName);

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isFavorite ? Colors.amber : null,
          ),
          tooltip: isFavorite ? t.remove_from_favorites : t.add_to_favorites,
          onPressed: () {
            appCubit.toggleFavorite(calculatorItem);
            AppSnackbar.showSuccess(
              message:
                  isFavorite ? t.removed_from_favorites : t.added_to_favorites,
            );
          },
        );
      },
    );
  }
}
