import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  static Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status == PermissionStatus.granted;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
