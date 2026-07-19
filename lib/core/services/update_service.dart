import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A newer release found on GitHub, ready to offer to the user.
class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.assetSizeBytes,
  });

  /// The release's version, with any leading "v" stripped (e.g. "1.2.0").
  final String version;

  /// Direct download URL for the release's .apk asset.
  final String downloadUrl;

  /// The release's description/changelog, as written on GitHub.
  final String releaseNotes;

  final int assetSizeBytes;
}

/// Checks GitHub Releases for a newer version of the app than what's
/// currently installed, and can download + launch the installer for it.
///
/// This only works for releases that have an actual `.apk` file attached as
/// a release asset — GitHub's auto-generated "Source code" archives aren't
/// installable, so a release with no .apk asset is treated as if there's no
/// update available.
class UpdateService {
  static const _owner = 'AbdallahSaeed0';
  static const _repo = 'my-salaat';
  static const _apiUrl = 'https://api.github.com/repos/$_owner/$_repo/releases/latest';
  static const _lastCheckKey = 'update_last_check_millis';
  static const _checkInterval = Duration(days: 1);

  /// Checks for an update. Unless [force] is true, this returns null
  /// without hitting the network if it already checked within
  /// [_checkInterval]. Network/parsing errors propagate as exceptions —
  /// callers doing a silent automatic on-launch check should catch and
  /// ignore them; a manual "Check for Updates" button should let them
  /// surface so the user gets feedback.
  Future<UpdateInfo?> checkForUpdate({bool force = false}) async {
    if (!Platform.isAndroid) return null;

    if (!force) {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckMillis = prefs.getInt(_lastCheckKey);
      if (lastCheckMillis != null) {
        final elapsed = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastCheckMillis));
        if (elapsed < _checkInterval) return null;
      }
    }

    final result = await _fetchLatestRelease();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
    return result;
  }

  Future<UpdateInfo?> _fetchLatestRelease() async {
    final response = await http
        .get(Uri.parse(_apiUrl), headers: {'Accept': 'application/vnd.github+json'})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final tagName = json['tag_name'] as String? ?? '';
    if (tagName.isEmpty) return null;
    final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

    final assets = (json['assets'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    Map<String, dynamic>? apkAsset;
    for (final asset in assets) {
      final name = (asset['name'] as String?)?.toLowerCase() ?? '';
      if (name.endsWith('.apk')) {
        apkAsset = asset;
        break;
      }
    }
    if (apkAsset == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    if (!_isNewer(latestVersion, packageInfo.version)) return null;

    return UpdateInfo(
      version: latestVersion,
      downloadUrl: apkAsset['browser_download_url'] as String,
      releaseNotes: (json['body'] as String?)?.trim() ?? '',
      assetSizeBytes: (apkAsset['size'] as num?)?.toInt() ?? 0,
    );
  }

  bool _isNewer(String latest, String current) {
    final l = _parseVersion(latest);
    final c = _parseVersion(current);
    for (var i = 0; i < 3; i++) {
      if (l[i] != c[i]) return l[i] > c[i];
    }
    return false;
  }

  List<int> _parseVersion(String version) {
    final withoutBuildNumber = version.split('+').first;
    final parts = withoutBuildNumber.split('.').map((p) => int.tryParse(p.trim()) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts;
  }

  /// Downloads the release APK to a temp file, reporting progress from 0.0
  /// to 1.0, then launches the system package installer for it. Throws on
  /// network/IO failure — callers should catch and show an error.
  Future<void> downloadAndInstall(
    UpdateInfo info, {
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(info.downloadUrl));
    final response = await http.Client().send(request);
    if (response.statusCode != 200) {
      throw HttpException('Download failed with status ${response.statusCode}');
    }

    final contentLength = response.contentLength ?? info.assetSizeBytes;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/my_salaat_update.apk');
    final sink = file.openWrite();

    var received = 0;
    await response.stream.listen((chunk) {
      received += chunk.length;
      sink.add(chunk);
      if (contentLength > 0) onProgress?.call(received / contentLength);
    }).asFuture<void>();
    await sink.close();

    final result = await OpenFilex.open(file.path, type: 'application/vnd.android.package-archive');
    if (result.type != ResultType.done) {
      throw StateError(result.message);
    }
  }
}
