import 'package:permission_handler/permission_handler.dart';

class PermissionUntil {
  static Future<bool> getPermission(Permission permission) async {
    PermissionStatus status = await permission.status;
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      return true;
    }
    {
      if (status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
        return false;
      }
      status = await permission.request();
      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited) {
        return true;
      }
      return false;
    }
  }

  static Future<void> permissionHandler({
    required Permission permission,
    required Function() onGranted,
    required Function() onDenied,
  }) async {
    PermissionStatus status = await permission.status;
    if (status.isGranted || status.isLimited || status.isProvisional) {
      onGranted();
      return;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      await openAppSettings();
      return;
    }
    status = await permission.request();
    if (status.isGranted || status.isLimited || status.isProvisional) {
      onGranted();
    } else {
      onDenied();
    }
  }
}
