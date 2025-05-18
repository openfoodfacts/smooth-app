import 'dart:async';
import 'package:sqlite3/wasm.dart';

class SqliteWebHelper {
  late WasmSqlite3 _sqlite3;
  late Database _database;

  Future<void> initialize() async {
    final Uri uri = Uri.parse('path/to/sqlite3.wasm');
    final HttpClientRequest request = await HttpClient().getUrl(uri);
    final HttpClientResponse response = await request.close();
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    final WasmModule module = WasmModule(bytes);
    _sqlite3 = WasmSqlite3(module);
    _database = _sqlite3.open('my_database');
  }

  Future<void> createTable() async {
    final String sql = '''
      CREATE TABLE IF NOT EXISTS my_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''';
    _database.execute(sql);
  }

  Future<void> insertData(String name) async {
    final String sql = 'INSERT INTO my_table (name) VALUES (?);';
    final Statement statement = _database.prepare(sql);
    statement.execute([name]);
    statement.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final String sql = 'SELECT * FROM my_table;';
    final ResultSet resultSet = _database.select(sql);
    final List<Map<String, dynamic>> data = [];
    for (final Row row in resultSet) {
      data.add({
        'id': row['id'],
        'name': row['name'],
      });
    }
    return data;
  }

  Future<void> updateData(int id, String name) async {
    final String sql = 'UPDATE my_table SET name = ? WHERE id = ?;';
    final Statement statement = _database.prepare(sql);
    statement.execute([name, id]);
    statement.dispose();
  }

  Future<void> deleteData(int id) async {
    final String sql = 'DELETE FROM my_table WHERE id = ?;';
    final Statement statement = _database.prepare(sql);
    statement.execute([id]);
    statement.dispose();
  }
}
