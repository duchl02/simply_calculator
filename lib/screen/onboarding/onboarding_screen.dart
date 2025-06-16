import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/core/extensions/theme_extension.dart';
import 'package:simply_calculator/gen/assets.gen.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _calculatorController;
  late AnimationController _titleController;
  late AnimationController _featuresController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _calculatorScaleAnimation;
  late Animation<double> _calculatorRotateAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late List<Animation<Offset>> _featureSlideAnimations;
  late Animation<double> _buttonScaleAnimation;

  // Features to showcase
  final List<FeatureItem> _features = [
    FeatureItem(
      icon: Icons.calculate_rounded,
      title: t.standard_calculator,
      color: Colors.blue,
    ),
    FeatureItem(
      icon: Icons.percent,
      title: t.discount_calculator,
      color: Colors.purple,
    ),
    FeatureItem(
      icon: Icons.payments_outlined,
      title: t.tip_calculator,
      color: Colors.amber,
    ),
    FeatureItem(
      icon: Icons.monitor_weight_outlined,
      title: t.bmi_calculator,
      color: Colors.green,
    ),
    FeatureItem(
      icon: Icons.date_range,
      title: t.date_calculator,
      color: Colors.orange,
    ),
    FeatureItem(
      icon: Icons.account_balance_outlined,
      title: t.loan_calculator,
      color: Colors.blueGrey,
    ),
  ];

  // Add these scale animations to your existing animation setup in initState()
  late List<Animation<double>> _featureScaleAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _calculatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _featuresController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Configure animations
    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_backgroundController);

    _calculatorScaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _calculatorController, curve: Curves.elasticOut),
    );

    _calculatorRotateAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _calculatorController,
        curve: Curves.easeOutCubic,
      ),
    );

    _titleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeIn));

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );

    // Fix the feature slide animations (which have the same issue)
    _featureSlideAnimations = List.generate(
      _features.length,
      (index) => Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _featuresController,
          curve: Interval(
            index * 0.15, // Stagger the animations
            min(1.0, 0.6 + index * 0.15), // Ensure end doesn't exceed 1.0
            curve: Curves.easeOutQuint,
          ),
        ),
      ),
    );

    // Fix the feature scale animations
    _featureScaleAnimations = List.generate(
      _features.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _featuresController,
          curve: Interval(
            index * 0.15, // Stagger the animations
            min(1.0, 0.6 + index * 0.15), // Ensure end doesn't exceed 1.0
            curve: Curves.elasticOut, 
          ),
        ),
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    // Start animations sequentially
    _calculatorController.forward().then((_) {
      _titleController.forward().then((_) {
        _featuresController.forward().then((_) {
          _buttonController.forward();
        });
      });
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _calculatorController.dispose();
    _titleController.dispose();
    _featuresController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    // Navigate to main calculator screen
    context.router.replace(const CalculatorRoute());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: OnboardingBackgroundPainter(
                  animation: _backgroundAnimation.value,
                  primaryColor: colorScheme.primary,
                  secondaryColor: colorScheme.secondary,
                ),
                child: Container(),
              );
            },
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.h),

                  // Calculator icon with animation
                  Center(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _calculatorScaleAnimation,
                        _calculatorRotateAnimation,
                      ]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _calculatorScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _calculatorRotateAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(30.r),
                          image: DecorationImage(
                            image: AssetImage(Assets.icons.appIcon.path),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Title with animation
                  FadeTransition(
                    opacity: _titleOpacityAnimation,
                    child: SlideTransition(
                      position: _titleSlideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              t.welcome_to_simply_calculator,
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onBackground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Center(
                            child: Text(
                              t.onboarding_main_description,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Features grid with staggered animations
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                      ),
                      itemCount: _features.length,
                      itemBuilder: (context, index) {
                        final feature = _features[index];
                        return SlideTransition(
                          position: _featureSlideAnimations[index],
                          child: ScaleTransition(
                            scale: _featureScaleAnimations[index],
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withOpacity(
                                    0.5,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: feature.color.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        feature.icon,
                                        color: feature.color,
                                        size: 20.sp,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Flexible(
                                      child: Text(
                                        feature.title,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Get Started button with animation
                  Center(
                    child: ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 16.h,
                          ),
                          elevation: 6,
                          shadowColor: colorScheme.primary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.get_started,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20.sp,
                              color: context.colorScheme.onPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for animated background
class OnboardingBackgroundPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;

  OnboardingBackgroundPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient background
    final Rect rect = Offset.zero & size;
    final Paint paint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.05),
              secondaryColor.withOpacity(0.1),
            ],
          ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Draw animated shapes in background
    for (int i = 0; i < 5; i++) {
      final offset = 0.2 * i;
      final shapePaint =
          Paint()
            ..color = primaryColor.withOpacity(0.08)
            ..style = PaintingStyle.fill;

      // Top-left shape
      final x1 = size.width * (0.1 + 0.2 * sin(animation * 2 * 3.14 + offset));
      final y1 = size.height * (0.1 + 0.1 * cos(animation * 2 * 3.14 + offset));
      final size1 = size.width * (0.2 + 0.05 * sin(animation * 3.14 + offset));

      canvas.drawCircle(Offset(x1, y1), size1, shapePaint);

      // Bottom-right shape
      final shapePaint2 =
          Paint()
            ..color = secondaryColor.withOpacity(0.08)
            ..style = PaintingStyle.fill;

      final x2 = size.width * (0.8 - 0.2 * cos(animation * 2 * 3.14 + offset));
      final y2 = size.height * (0.7 - 0.1 * sin(animation * 2 * 3.14 + offset));
      final size2 = size.width * (0.15 + 0.05 * sin(animation * 3.14 + offset));

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x2, y2), width: size2, height: size2),
        Radius.circular(size2 * 0.3),
      );

      canvas.drawRRect(rect, shapePaint2);
    }
  }

  @override
  bool shouldRepaint(OnboardingBackgroundPainter oldDelegate) => true;
}

// Model class for feature items
class FeatureItem {
  final IconData icon;
  final String title;
  final Color color;

  FeatureItem({required this.icon, required this.title, required this.color});
}
