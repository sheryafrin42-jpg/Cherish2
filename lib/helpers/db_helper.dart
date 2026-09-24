import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'cherish_app.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE user_products(id TEXT PRIMARY KEY, title TEXT, price REAL, imageUrl TEXT, description TEXT)',
        );
        // Tabel khusus menyimpan data keranjang
        await db.execute(
          'CREATE TABLE cart_items(id TEXT PRIMARY KEY, productId TEXT, title TEXT, price REAL, quantity INTEGER, imageUrl TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS cart_items(id TEXT PRIMARY KEY, productId TEXT, title TEXT, price REAL, quantity INTEGER, imageUrl TEXT)',
          );
        }
      },
      version: 2,
    );
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    await db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<void> delete(String table, String id) async {
    final db = await DBHelper.database();
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearTable(String table) async {
    final db = await DBHelper.database();
    await db.delete(table);
  }
}