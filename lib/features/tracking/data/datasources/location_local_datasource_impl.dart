import 'package:background_location_tracker/features/tracking/data/datasources/location_local_datasource.dart';
import 'package:background_location_tracker/features/tracking/data/models/location_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocationLocalDatasourceImpl implements LocationLocalDataSource {
  static const _dbName = 'background_locations.db';
  static const _tableName = 'locations';
  static Database? _database;

  const LocationLocalDatasourceImpl();

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }

    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/$_dbName';

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            accuracy REAL NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  @override
  Future<List<LocationModel>> getLocations() async {
    final database = await _db;
    final rows = await database.query(_tableName, orderBy: 'id DESC');

    return rows
        .map((row) => LocationModel.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<void> saveLocation(LocationModel location) async {
    final database = await _db;
    await database.insert(
      _tableName,
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> clearLocations() async {
    final database = await _db;
    await database.delete(_tableName);
  }
}
