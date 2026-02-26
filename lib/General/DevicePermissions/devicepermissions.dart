import 'package:permission_handler/permission_handler.dart';

class DevicePermissions {
  static Future<void> requestAudioPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      await Permission.microphone.request();
    }
  }
}
