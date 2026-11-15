import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class MealsDatabase {
  MealsDatabase({required this.getDatabasesPath, required this.openDb});

  final Future<String> Function() getDatabasesPath;
  final Future<Database> Function(String path, {bool readOnly}) openDb;

  static const _name = 'meals.db';
  Database? _database;

  /// Returns the same instance if already open, or opens it.
  Future<Database> get instance async {
    final db = _database;
    if (db != null && db.isOpen) return db;

    final dir = await getDatabasesPath();
    return _database = await openDb(p.join(dir, _name), readOnly: true);
  }

  // Close database
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) await db.close();
    _database = null;
  }
}
