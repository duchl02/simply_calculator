import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/core/managers/feature_tips_manager.dart';
import 'package:simply_calculator/core/style/flex_theme/flex_scheme.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';

@RoutePage()
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  final PageController _pageController = PageController();
  final ScrollController _listController = ScrollController();
  int _currentIndex = 0;

  // Danh sách các theme muốn hiển thị (bỏ qua một số theme không phổ biến)
  final List<FlexScheme> availableThemes =
      FlexScheme.values
          .where(
            (theme) =>
                theme != FlexScheme.flutterDash &&
                theme != FlexScheme.shadBlue &&
                theme != FlexScheme.shadGreen &&
                theme != FlexScheme.shadOrange &&
                theme != FlexScheme.shadRed &&
                theme != FlexScheme.shadYellow &&
                theme != FlexScheme.shadNeutral &&
                theme != FlexScheme.shadZinc &&
                theme != FlexScheme.shadSlate &&
                theme != FlexScheme.shadGray &&
                theme != FlexScheme.shadStone &&
                theme != FlexScheme.shadRose &&
                theme != FlexScheme.shadViolet,
          )
          .toList();

  @override
  void initState() {
    super.initState();
    _initCurrentTheme();
    FeatureTipsManager.markFeatureAsUsed(ThemeSettingsRoute.name);
  }

  void _initCurrentTheme() {
    final appCubit = context.read<AppCubit>();
    final currentTheme = appCubit.state.theme;
    _currentIndex = availableThemes.indexOf(currentTheme);
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }

      if (_listController.hasClients) {
        _scrollToSelectedItem();
      }
    });
  }

  void _scrollToSelectedItem() {
    if (!_listController.hasClients) {
      return;
    }

    const itemHeight = 64.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final offset =
        _currentIndex * itemHeight - (screenHeight / 2) + (itemHeight / 2);

    if (offset > 0) {
      _listController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return AppScaffold(
          title: t.theme,
          body: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: _buildThemeList(state),
              ),
              Container(width: 1, color: Theme.of(context).dividerColor),
              Expanded(child: _buildThemePreview(state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeList(AppState state) {
    return ListView.builder(
      controller: _listController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: availableThemes.length,
      itemBuilder: (context, index) {
        final theme = availableThemes[index];
        final isSelected = index == _currentIndex;
        final primaryColor = theme.data.light.primary;
        final secondaryColor = theme.data.light.secondary;

        return Material(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _currentIndex = index;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                context.read<AppCubit>().setTheme(theme);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Theme color indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryColor, secondaryColor],
                      ),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _getDisplayName(theme),
                      style: TextStyle(
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemePreview(AppState state) {
    return PageView.builder(
      controller: _pageController,
      itemCount: availableThemes.length,
      onPageChanged: (index) {
        // setState(() {
        //   _currentIndex = index;
        // });
        // Future.delayed(const Duration(milliseconds: 500), () {
        //   context.read<AppCubit>().setTheme(availableThemes[index]);
        // });

        // if (_listController.hasClients) {
        //   const itemHeight = 64.0;
        //   final offset = index * itemHeight;

        //   if (offset < _listController.offset ||
        //       offset >
        //           _listController.offset +
        //               _listController.position.viewportDimension -
        //               itemHeight) {
        //     _listController.animateTo(
        //       offset - 100, // Position with some padding
        //       duration: const Duration(milliseconds: 300),
        //       curve: Curves.easeInOut,
        //     );
        //   }
        // }
      },
      itemBuilder: (context, index) {
        final theme = availableThemes[index];
        return _buildThemePreviewCard(theme);
      },
    );
  }

  Widget _buildThemePreviewCard(FlexScheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme name
          Text(
            _getDisplayName(theme),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Dark Mode Toggle
          _buildDarkModeToggle(),

          const SizedBox(height: 24),

          // Color samples
          _buildColorSample(t.primary_color, theme.data.light.primary),
          _buildColorSample(
            t.primary_container,
            theme.data.light.primaryContainer,
          ),
          _buildColorSample(t.secondary_color, theme.data.light.secondary),
          _buildColorSample(
            t.secondary_container,
            theme.data.light.secondaryContainer,
          ),
          _buildColorSample(t.tertiary_color, theme.data.light.tertiary),
          _buildColorSample(
            t.tertiary_container,
            theme.data.light.tertiaryContainer,
          ),
          _buildColorSample(t.error_color, theme.data.light.error!),

          const SizedBox(height: 32),

          // UI Component samples
          _buildComponentSamples(),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.appearance,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _buildThemeModeOption(
                      icon: Icons.brightness_5,
                      title: t.light_mode,
                      isSelected: state.themeMode == ThemeMode.light,
                      onTap: () {
                        context.read<AppCubit>().setThemeMode(ThemeMode.light);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildThemeModeOption(
                      icon: Icons.brightness_4,
                      title: t.dark_mode,
                      isSelected: state.themeMode == ThemeMode.dark,
                      onTap: () {
                        context.read<AppCubit>().setThemeMode(ThemeMode.dark);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildThemeModeOption(
                      icon: Icons.brightness_auto,
                      title: t.system_theme,
                      isSelected: state.themeMode == ThemeMode.system,
                      onTap: () {
                        context.read<AppCubit>().setThemeMode(ThemeMode.system);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSample(String label, Color color) {
    final textColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Center(
              child: Text(
                color.value.toRadixString(16).toUpperCase().substring(2),
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentSamples() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.ui_components_preview,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(onPressed: () {}, child: Text(t.elevated)),
                FilledButton(onPressed: () {}, child: Text(t.filled)),
                OutlinedButton(onPressed: () {}, child: Text(t.outlined)),
                TextButton(onPressed: () {}, child: Text(t.text)),
              ],
            ),

            const SizedBox(height: 16),

            // Input fields
            TextField(
              decoration: InputDecoration(
                labelText: t.text_field,
                hintText: t.enter_text,
              ),
              controller: TextEditingController(text: t.sample_text),
            ),

            const SizedBox(height: 16),

            // Switch and checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (_) {}),
                    Text(t.checkbox),
                  ],
                ),
                Switch(value: true, onChanged: (_) {}),
              ],
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(t.chip_1), avatar: const Icon(Icons.star)),
                Chip(label: Text(t.chip_2), avatar: const Icon(Icons.favorite)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(FlexScheme theme) {
    final name = theme.data.name;

    return name;
  }
}
