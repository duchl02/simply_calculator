import 'package:flutter/material.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showRateAppDialog(BuildContext context) async {
  int selectedRating = 0;
  final TextEditingController feedbackController = TextEditingController();
  bool showFeedbackField = false;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          
          return Dialog(
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surfaceTint,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.rate_our_app,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => Navigator.pop(context),
                        tooltip: t.close,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  
                  // Rating question
                  Text(
                    t.how_would_you_rate_app,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        iconSize: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        icon: Icon(
                          selectedRating >= starIndex
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: selectedRating >= starIndex
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = starIndex;
                            // Hiển thị field feedback khi đánh giá thấp (1-3 sao)
                            showFeedbackField = (starIndex <= 3);
                          });
                        },
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rating label
                  Text(
                    _getRatingLabelText(selectedRating),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Feedback field for low ratings
                  if (showFeedbackField) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: t.tell_us_how_to_improve,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Secondary action: "Later"
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(t.later),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Primary action: "Submit" or "Rate on Store"
                      FilledButton(
                        onPressed: selectedRating == 0 ? null : () {
                          if (selectedRating >= 4) {
                            _openAppStore();
                          } else {
                            // Submit feedback
                            _submitFeedback(
                              rating: selectedRating,
                              feedback: feedbackController.text,
                            );
                          }
                          Navigator.pop(context);
                        },
                        child: Text(selectedRating >= 4 ? t.rate_on_store : t.submit),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

String _getRatingLabelText(int rating) {
  switch (rating) {
    case 1:
      return t.very_dissatisfied;
    case 2:
      return t.dissatisfied;  
    case 3:
      return t.neutral;
    case 4:
      return t.satisfied;
    case 5:
      return t.very_satisfied;
    default:
      return t.tap_star_to_rate;
  }
}

// Mở app store để đánh giá
Future<void> _openAppStore() async {
  // final Uri url;
  // if (Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.iOS) {
  //   url = Uri.parse('https://apps.apple.com/app/id123456789');
  // } else {
  //   url = Uri.parse('https://play.google.com/store/apps/details?id=com.simply_crafted.calculator');
  // }

  // if (await canLaunchUrl(url)) {
  //   await launchUrl(url);
  // }
}

// Gửi feedback khi đánh giá thấp
Future<void> _submitFeedback({required int rating, required String feedback}) async {
  // TODO: Implement feedback submission
  // Có thể gửi đến server, Firebase, email, hoặc lưu local
  print('Rating: $rating, Feedback: $feedback');
}