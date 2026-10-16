import 'package:path/path.dart' as paths;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Database? _database;

  Future<void> initialize() async {
    final base = await getDatabasesPath();
    _database = await openDatabase(
      paths.join(base, 'app ponte.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE announcements (
          id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL,
          body TEXT NOT NULL, created_at TEXT NOT NULL, pinned INTEGER NOT NULL DEFAULT 0
        )''');
        await db.execute('''CREATE TABLE events (
          id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL,
          details TEXT NOT NULL, starts_at TEXT NOT NULL, location TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE social_posts (
          id INTEGER PRIMARY KEY AUTOINCREMENT, author TEXT NOT NULL,
          body TEXT NOT NULL, created_at TEXT NOT NULL
        )''');
        final now = DateTime.now();
        await db.insert('announcements', {
          'title': 'Benvenuti in Quartiere Ponte',
          'body': 'Questo è il nostro spazio comune. Qui troverete le novità, gli appuntamenti e le storie del quartiere.',
          'created_at': now.toIso8601String(), 'pinned': 1,
        });
        await db.insert('events', {
          'title': 'Aperitivo sul ponte',
          'details': 'Un momento informale per incontrarsi e conoscere i vicini.',
          'starts_at': DateTime(now.year, now.month, now.day + 3, 18, 30).toIso8601String(),
          'location': 'Piazza del Ponte',
        });
        await db.insert('social_posts', {
          'author': 'La comunità',
          'body': 'Hai una notizia, una domanda o qualcosa da condividere? Questo spazio è tuo.',
          'created_at': now.toIso8601String(),
        });
      },
    );
  }

  Future<List<Map<String, Object?>>> getItems(String table) async {
    const allowed = {'announcements', 'events', 'social_posts'};
    if (!allowed.contains(table)) throw ArgumentError.value(table, 'table');
    return _database!.query(table, orderBy: table == 'events' ? 'starts_at ASC' : 'id DESC');
  }

  Future<void> addPost(String body) async {
    await _database!.insert('social_posts', {
      'author': 'Tu', 'body': body, 'created_at': DateTime.now().toIso8601String(),
    });
  }
}
