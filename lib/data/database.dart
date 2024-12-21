import 'package:demo_app/data/models.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _databasePath = 'app_database.db';
  static const String _generatePackageQuery = r'''
CREATE TABLE IF NOT EXISTS "packages" (
	"id" TEXT NOT NULL UNIQUE,
	"title" TEXT,
	"description" TEXT,
	"createdAt" DATETIME,
	"image" TEXT,
	PRIMARY KEY("id")
)''';

  static const String _generateWordQuery = r'''
CREATE TABLE IF NOT EXISTS "words" (
	"id" TEXT NOT NULL UNIQUE,
	"package_id" TEXT,
	"front" TEXT,
	"back" TEXT,
	"frontType" INTEGER,
	"backType" INTEGER,
	PRIMARY KEY("id"),
	FOREIGN KEY ("package_id") REFERENCES "packages"("id")
	ON UPDATE NO ACTION ON DELETE CASCADE
);
''';

  AppDatabase._();

  late final Database _database;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  static final AppDatabase instance = AppDatabase._();

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _database = await openDatabase(
      _databasePath,
      version: 2,
      onCreate: (db, _) async {
        await db.execute(_generatePackageQuery);
        await db.execute(_generateWordQuery);
      },
    );
    _isInitialized = true;
  }

  Future<PackageModel> createPackage(PackageModel package) async {
    await _database.insert('packages', package.toJson());
    return package;
  }

  Future<PackageModel> updatePackage(PackageModel package) async {
    await _database.update(
      'packages',
      package.toJson(),
      where: 'id = ?',
      whereArgs: [package.id],
    );
    return package;
  }

  Future<void> deletePackage(String id) async {
    await _database.delete(
      'packages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PackageModel>> getPackages() async {
    final List<Map<String, dynamic>> maps = await _database.query('packages');
    return List.generate(maps.length, (i) {
      return PackageModel(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        image: maps[i]['image'],
      );
    });
  }

  Future<WordModel> createWord(WordModel word) async {
    await _database.insert('words', word.toJson());
    return word;
  }

  Future<WordModel> updateWord(WordModel word) async {
    await _database.update(
      'words',
      word.toJson(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
    return word;
  }

  Future<void> deleteWord(String id) async {
    await _database.delete(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<WordModel>> getWords(String packageId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'words',
      where: 'package_id = ?',
      whereArgs: [packageId],
    );
    return List.generate(maps.length, (i) => WordModel.fromJson(maps[i]));
  }
}
