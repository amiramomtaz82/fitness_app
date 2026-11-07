import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fitness_app/features/chat/data/models/db_info.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class DBsAssetInstaller {
  DBsAssetInstaller({
    required AssetBundle assetBundle,
    required SharedPreferences prefs,
    required Future<String> Function() getDatabasesPath,
  }) : _assetBundle = assetBundle,
       _prefs = prefs,
       _getDatabasesPath = getDatabasesPath;

  final AssetBundle _assetBundle;
  final SharedPreferences _prefs;
  final Future<String> Function() _getDatabasesPath;

  static const dbs = ['exercises.db', 'meals.db'];
  static const _assetsFolder = 'assets/database';

  static String versionKey(String dbName) => 'db_version_$dbName';

  /// Idempotent: safe to call on every app launch.
  /// For each database: copies it only if the bundled version changed
  /// or the file is missing.
  Future<void> ensureInstalled() async {
    final manifest =
        jsonDecode(
              await _assetBundle.loadString('$_assetsFolder/manifest.json'),
            )
            as Map<String, dynamic>;

    final dir = await _getDatabasesPath();
    await Directory(dir).create(recursive: true);

    for (final name in dbs) {
      final info = DbInfo.fromJson(manifest[name] as Map<String, dynamic>);
      await _installIfNeeded(name, info, dir);
    }
  }

  Future<void> _installIfNeeded(String name, DbInfo info, String dir) async {
    final target = File(p.join(dir, name));
    final installedVersion = _prefs.getInt(versionKey(name));

    // Nothing to do
    if (installedVersion == info.version && await target.exists()) return;

    final bytes = await _assetBundle.load('$_assetsFolder/$name');
    final data = bytes.buffer.asUint8List(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );

    // Check the hash before copying
    if (sha256.convert(data).toString() != info.hash.toLowerCase()) {
      throw StateError('checksum mismatch for $name — corrupt asset');
    }

    // Copy to a tmp file first, so a kill mid-copy
    // doesn't leave a truncated database
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(data, flush: true);

    if (await target.exists()) await target.delete();
    await tmp.rename(target.path);

    await _prefs.setInt(versionKey(name), info.version);
  }
}
