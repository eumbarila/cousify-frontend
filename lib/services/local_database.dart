import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  // Singleton pattern
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'coursify_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE downloaded_courses (
        course_id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        video_url TEXT,
        video_path TEXT,
        thumbnail_url TEXT,
        progress REAL DEFAULT 0,
        is_synced INTEGER DEFAULT 1,
        downloaded_at TEXT,
        last_updated TEXT
      )
    ''');
  }

  // === CRUD Operations ===

  // Guardar curso descargado
  static Future<void> saveCourse({
    required int courseId,
    required String title,
    String? description,
    String? videoUrl,
    required String videoPath,
    String? thumbnailUrl,
  }) async {
    final db = await database;
    await db.insert(
      'downloaded_courses',
      {
        'course_id': courseId,
        'title': title,
        'description': description,
        'video_url': videoUrl,
        'video_path': videoPath,
        'thumbnail_url': thumbnailUrl,
        'progress': 0,
        'is_synced': 1,
        'downloaded_at': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener todos los cursos descargados
  static Future<List<Map<String, dynamic>>> getAllDownloadedCourses() async {
    final db = await database;
    return await db.query('downloaded_courses', orderBy: 'downloaded_at DESC');
  }

  // Obtener un curso específico
  static Future<Map<String, dynamic>?> getCourse(int courseId) async {
    final db = await database;
    final results = await db.query(
      'downloaded_courses',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Verificar si un curso está descargado
  static Future<bool> isCourseDownloaded(int courseId) async {
    final course = await getCourse(courseId);
    return course != null;
  }

  // Actualizar progreso localmente
  static Future<void> updateProgress(int courseId, double progress) async {
    final db = await database;
    await db.update(
      'downloaded_courses',
      {
        'progress': progress,
        'is_synced': 0, // Marcar como no sincronizado
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }

  // Marcar como sincronizado
  static Future<void> markAsSynced(int courseId) async {
    final db = await database;
    await db.update(
      'downloaded_courses',
      {'is_synced': 1},
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }

  // Obtener cursos no sincronizados
  static Future<List<Map<String, dynamic>>> getUnsyncedCourses() async {
    final db = await database;
    return await db.query(
      'downloaded_courses',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  // Eliminar curso descargado
  static Future<void> deleteCourse(int courseId) async {
    final db = await database;
    await db.delete(
      'downloaded_courses',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }

  // Limpiar toda la base de datos (útil para testing)
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('downloaded_courses');
  }
}
