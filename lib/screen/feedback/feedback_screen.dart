import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/widgets/scaffold/app_scaffold.dart';
import 'package:simply_calculator/screen/widgets/snack_bar/app_snackbar.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _controller = TextEditingController();
  String selectedType = 'bug';
  final List<File> _attachedImages = []; // Danh sách ảnh đính kèm
  final ImagePicker _picker = ImagePicker(); // Image picker
  final int maxImages = 3; // Số lượng ảnh tối đa

  final feedbackOptions = [
    {
      'type': 'suggestion',
      'label': t.suggestion,
      'icon': Icons.lightbulb_outline,
    },
    {'type': 'bug', 'label': t.bug_report, 'icon': Icons.bug_report_outlined},
    {
      'type': 'feature',
      'label': t.feature_request,
      'icon': Icons.new_releases_outlined,
    },
    {'type': 'other', 'label': t.other, 'icon': Icons.more_horiz},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      resizeToAvoidBottomInset: false,
      title: t.feedback,
      hasFeedbackButton: false,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.select_feedback_type,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  feedbackOptions.map((option) {
                    final isSelected = selectedType == option['type'];
                    return _buildFeedbackTypeOption(
                      context: context,
                      icon: option['icon'] as IconData,
                      label: option['label'] as String,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => selectedType = option['type'] as String);
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            Text(
              t.your_message,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 8,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: t.write_feedback_here,
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Phần chọn ảnh đính kèm - THÊM MỚI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.attachments,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_attachedImages.length}/$maxImages ${t.images}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Hiển thị ảnh đính kèm
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  // Button thêm ảnh
                  if (_attachedImages.length < maxImages)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 32,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.add_image,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Hiển thị các ảnh đã chọn
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachedImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            // Hình ảnh
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _attachedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Nút xóa
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _attachedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _submitFeedback,
                icon: const Icon(Icons.send_rounded),
                label: Text(
                  t.submit_feedback,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_attachedImages.length >= maxImages) {
      AppSnackbar.showInfo(message: t.max_images_limit(s: maxImages));
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _attachedImages.add(File(image.path));
        });
      }
    } catch (e) {
      AppSnackbar.showError(message: t.could_not_access_gallery);
    }
  }

  void _submitFeedback() async {
    final msg = _controller.text.trim();
    if (msg.isNotEmpty) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Chuẩn bị và gửi feedback
        final success = await _prepareAndSendFeedback(msg);

        // Đóng loading indicator
        Navigator.of(context).pop();

        if (success) {
          AppSnackbar.showSuccess(message: t.feedback_thank_you);

          // Reset form
          _controller.clear();
          setState(() {
            _attachedImages.clear();
          });

          // Quay lại màn hình trước đó sau khi gửi thành công
          Future.delayed(const Duration(milliseconds: 500), () {
            context.router.pop();
          });
        } else {
          AppSnackbar.showError(message: t.email_app_not_found);
        }
      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
        AppSnackbar.showError(message: '${t.feedback_error}: ${e.toString()}');
        print('Feedback error: ${e.toString()}');
      }
    } else {
      AppSnackbar.showInfo(message: t.feedback_empty_message);
    }
  }

  Widget _buildFeedbackTypeOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color:
                    isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color:
                  isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Thêm vào class _FeedbackScreenState
  Future<bool> _prepareAndSendFeedback(String message) async {
    try {
      // 1. Lấy thông tin thiết bị
      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> deviceData = {};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'device': androidInfo.model,
          'brand': androidInfo.brand,
          'androidVersion': androidInfo.version.release,
          'sdkVersion': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'device': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
        };
      }

      // 2. Lấy thông tin ứng dụng
      final packageInfo = await PackageInfo.fromPlatform();
      final appInfo = {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
      final List<List<int>> imageBytes = [];
      for (final image in _attachedImages) {
        final bytes = await image.readAsBytes();
        imageBytes.add(bytes);
      }
      // 3. Tạo dữ liệu JSON
      final timestamp = DateTime.now().toIso8601String();
      final feedbackJson = {
        'type': selectedType,
        'message': message,
        'timestamp': timestamp,
        'deviceInfo': deviceData,
        'appInfo': appInfo,
      };

      // 4. Tạo thư mục tạm để lưu trữ dữ liệu
      final tempDir = await getTemporaryDirectory();
      final feedbackDir = Directory(
        '${tempDir.path}/feedback_${timestamp.replaceAll(':', '-')}',
      );
      if (!feedbackDir.existsSync()) {
        feedbackDir.createSync();
      }

      // 5. Lưu file JSON
      final jsonFile = File('${feedbackDir.path}/feedback.json');
      await jsonFile.writeAsString(jsonEncode(feedbackJson));

      // 6. Sao chép các file ảnh vào thư mục tạm
      for (int i = 0; i < _attachedImages.length; i++) {
        final imageFile = _attachedImages[i];
        final newImagePath =
            '${feedbackDir.path}/image_$i${path.extension(imageFile.path)}';
        await imageFile.copy(newImagePath);
      }

      // 7. Nén thư mục thành file ZIP
      final zipFile = File('${tempDir.path}/feedback_$timestamp.zip');
      await _zipDirectory(feedbackDir.path, zipFile.path);

      // 8. Gửi email với file đính kèm
      return await _sendEmailWithAttachment(zipFile.path);
    } catch (e) {
      print('Error preparing feedback: $e');
      rethrow;
    }
  }

  Future<void> _zipDirectory(String sourceDir, String zipFilePath) async {
    final archive = Archive();
    final directory = Directory(sourceDir);
    final files = directory.listSync(recursive: true);

    for (var file in files) {
      if (file is File) {
        final relativePath = path.relative(file.path, from: sourceDir);
        final data = file.readAsBytesSync();
        archive.addFile(ArchiveFile(relativePath, data.length, data));
      }
    }

    final zipData = ZipEncoder().encode(archive);
    await File(zipFilePath).writeAsBytes(zipData);
  }

  Future<bool> _sendEmailWithAttachment(String attachmentPath) async {
    final Email email = Email(
      body: '${t.feedback_message_from} Simply Calculator\n\n',
      subject: '${t.feedback}: ${_getFeedbackTypeName(selectedType)}',
      recipients: [AppConst.emailSupport],
      attachmentPaths: [attachmentPath],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    return true;
  }

  String _getFeedbackTypeName(String type) {
    for (final option in feedbackOptions) {
      if (option['type'] == type) {
        return option['label'] as String;
      }
    }
    return type;
  }
}
