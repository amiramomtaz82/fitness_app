import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fitness_app/features/chat/data/models/db_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  final Map<String, Database> _databases = {};

  // Read database information from manifest
  Future<DbInfo> readDbInfo(String dbName) async {
    final text = await rootBundle.loadString('assets/database/manifest.json');

    final map = jsonDecode(text) as Map<String, dynamic>;

    return DbInfo.fromJson(map[dbName] as Map<String, dynamic>);
  }

  // Get database file path on the device
  Future<String> getDbPath(String dbName) async {
    final folder = await getDatabasesPath();
    return join(folder, dbName);
  }

  // Check if database file exists on the device
  Future<bool> dbExists(String dbName) async {
    final path = await getDbPath(dbName);
    return File(path).exists();
  }

  // Check if database needs an update
  Future<bool> needsUpdate(String dbName) async {
    final dbInfo = await readDbInfo(dbName);
    final prefs = await SharedPreferences.getInstance();

    final savedVersion = prefs.getInt('${dbName}_version');

    if (savedVersion == null) {
      return true;
    }

    return dbInfo.version > savedVersion;
  }

  // Copy database from assets to a temporary file
  Future<String> copyDatabaseToTemp(String dbName) async {
    final dbPath = await getDbPath(dbName);
    final tempPath = '$dbPath.tmp';

    final data = await rootBundle.load('assets/database/$dbName');

    final tempFile = File(tempPath);

    await tempFile.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );

    return tempPath;
  }

  // Calculate SHA-256 hash for a file
  Future<String> calculateFileHash(String filePath) async {
    final file = File(filePath);
    final hash = await sha256.bind(file.openRead()).first;

    return hash.toString();
  }

  // Verify that the temporary file matches the manifest hash
  Future<bool> verifyTempHash(String dbName) async {
    final dbInfo = await readDbInfo(dbName);
    final dbPath = await getDbPath(dbName);
    final tempPath = '$dbPath.tmp';

    final tempFile = File(tempPath);

    if (!await tempFile.exists()) {
      return false;
    }

    final actualHash = await calculateFileHash(tempPath);
    final expectedHash = dbInfo.hash.toLowerCase();

    if (actualHash.toLowerCase() != expectedHash) {
      await tempFile.delete();
      return false;
    }

    return true;
  }

  // Open database
  Future<Database> openLocalDatabase(String dbName) async {
    if (_databases.containsKey(dbName)) {
      final database = _databases[dbName]!;

      if (database.isOpen) {
        return database;
      }
    }

    final dbPath = await getDbPath(dbName);

    final database = await openDatabase(dbPath, readOnly: true);

    _databases[dbName] = database;

    return database;
  }

  // Close database
  Future<void> closeDatabase(String dbName) async {
    final database = _databases.remove(dbName);

    if (database != null && database.isOpen) {
      await database.close();
    }
  }

  // Print database tables and columns
  


}
