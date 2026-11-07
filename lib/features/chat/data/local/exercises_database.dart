import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ExercisesDatabase {
  ExercisesDatabase({
    required Future<String> Function() getDatabasesPath,
    required Future<Database> Function(String path, {bool readOnly}) openDb,
  }) : _getDatabasesPath = getDatabasesPath,
       _openDb = openDb;

  final Future<String> Function() _getDatabasesPath;
  final Future<Database> Function(String path, {bool readOnly}) _openDb;

  static const _name = 'exercises.db';
  Database? _database;

  /// Returns the same instance if already open, or opens it.
  Future<Database> get instance async {
    final db = _database;
    if (db != null && db.isOpen) return db;

    final dir = await _getDatabasesPath();
    return _database = await _openDb(p.join(dir, _name), readOnly: true);
  }

  // Close database
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) await db.close();
    _database = null;
  }
}
