import 'package:dio/dio.dart';
import 'package:dji_mapper/main.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Experimental class to check for updates using GitHub API
class UpdateChecker {
  /// Check for updates
  ///
  /// Returns `true` if there is an update available
  static Future<String?> checkForUpdate() async {
    try {
      final response = await Dio().get(
          "https://api.github.com/repos/YarosMallorca/DJI-Mapper/releases");
      final String latestVersion = response.data[0]["tag_name"];
      final currentVersion =
          await PackageInfo.fromPlatform().then((value) => value.version);

      // The only flaw here is that it isn't possible to check if the release
      // number is higher than the current version. Only if it's different.
      return latestVersion != currentVersion &&
              prefs.getString("ignoreVersion") != latestVersion
          ? latestVersion
          : null;
    } catch (e) {
      return null;
    }
  }
}
