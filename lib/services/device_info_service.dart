import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  Future<String> deviceModel() async {
    final info = await _plugin.androidInfo;
    return '${info.manufacturer} ${info.model}';
  }

  Future<String> osVersion() async {
    final info = await _plugin.androidInfo;
    return 'Android ${info.version.release} (SDK ${info.version.sdkInt})';
  }
}