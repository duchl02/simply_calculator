import 'package:permission_handler/permission_handler.dart';

extension PermissionStatusExtension on PermissionStatus {
  bool get isAccess => this == PermissionStatus.granted || this == PermissionStatus.limited || this == PermissionStatus.provisional;
  bool get isDenied => this == PermissionStatus.denied || this == PermissionStatus.restricted;
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
}
