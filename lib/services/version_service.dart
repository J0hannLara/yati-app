import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static const String versionUrl =
      "https://yati-app.pages.dev/version.json";

  static Future<Map<String, dynamic>> checkVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final response = await http.get(Uri.parse(versionUrl));
    final data = jsonDecode(response.body);

    final minVersion = data["minVersion"];
    final latestVersion = data["latestVersion"];
    final forceUpdate = data["forceUpdate"];
    final updateUrl = data["updateUrl"];

    return {
      "currentVersion": currentVersion,
      "minVersion": minVersion,
      "latestVersion": latestVersion,
      "forceUpdate": forceUpdate,
      "updateUrl": updateUrl,
      "needsUpdate": _isVersionLower(currentVersion, minVersion),
    };
  }

  static bool _isVersionLower(String current, String min) {
    List<int> cv = current.split('.').map(int.parse).toList();
    List<int> mv = min.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (cv[i] < mv[i]) return true;
      if (cv[i] > mv[i]) return false;
    }
    return false;
  }
}
