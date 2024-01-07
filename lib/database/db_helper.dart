import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/blog_model.dart';


class DBHelper {
  DBHelper._(); // Constructeur privé

  static final DBHelper instance = DBHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'blog_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blogs (
        id INTEGER PRIMARY KEY,
        title TEXT,
        content TEXT
      )
    ''');
  }

  Future<int> insertBlog(Blog blog) async {
    Database db = await instance.database;
    return await db.insert('blogs', blog.toMap());
  }

  Future<List<Blog>> getAllBlogs() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('blogs');
    return List.generate(maps.length, (index) {
      return Blog.fromMap(maps[index]);
    });
  }

  Future<int> updateBlog(Blog blog) async {
    Database db = await instance.database;
    return await db.update('blogs', blog.toMap(), where: 'id = ?', whereArgs: [blog.id]);
  }

  Future<int> deleteBlog(int id) async {
    Database db = await instance.database;
    return await db.delete('blogs', where: 'id = ?', whereArgs: [id]);
  }
}
