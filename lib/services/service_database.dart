import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "db_reciclaje.db");

    final database = openDatabase(
      databasePath,
      version: 2,
      onCreate: createDatabase,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1 && newVersion == 2) {
          await db.execute('''
            ALTER TABLE Ingreso ADD COLUMN IdDraftIngreso INTEGER NOT NULL;
          ''');
        }
      },
    );

    return database;
  }
}

void createDatabase(Database db, int version) async {
  await db.execute('''
        CREATE TABLE Material (
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          Nombre TEXT NOT NULL,
          PrecioKilo REAL NOT NULL,
          Stock REAL NOT NULL
        );''');

  await db.execute('''
        CREATE TABLE Ingreso (
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          IdDraftIngreso INTEGER NOT NULL,
          Detalle TEXT NOT NULL,
          NombreVendedor TEXT NOT NULL,
          FechaCreado TEXT NOT NULL,
          FechaConfirmado TEXT NOT NULL
        );''');

  await db.execute('''
        CREATE TABLE MaterialIngreso (
          IdMaterial INTEGER NOT NULL,
          IdIngreso INTEGER NOT NULL,
          Peso REAL NOT NULL
        );''');

  await db.execute('''
        CREATE TABLE DraftIngreso (
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          Detalle TEXT NOT NULL,
          Total REAL NOT NULL,
          NombreVendedor TEXT NOT NULL,
          FechaCreado TEXT NOT NULL,
          Confirmado INTEGER NOT NULL
        );''');

  await db.execute('''
        CREATE TABLE MaterialDraftIngreso (
          IdMaterial INTEGER NOT NULL,
          IdDraftIngreso INTEGER NOT NULL,
          Peso REAL NOT NULL
        );''');

  await db.execute('''CREATE TABLE Egreso (
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          Detalle TEXT NOT NULL,
          Total REAL NOT NULL,
          NombreVendedor TEXT NOT NULL,
          FechaCreado TEXT NOT NULL
        );''');

  await db.execute('''CREATE TABLE MaterialEgreso (
          IdMaterial INTEGER NOT NULL,
          IdEgreso INTEGER NOT NULL,
          Peso REAL NOT NULL
        );''');

  await db.execute('''CREATE TABLE Usuario (
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          Nombre TEXT NOT NULL,
          LastName1 TEXT,
          LastName2 TEXT,
          Email TEXT NOT NULL UNIQUE,
          Password TEXT NOT NULL,
          ProfilePictureUrl TEXT,
          Role TEXT NOT NULL DEFAULT 'Usuario'
        );''');
}


Future<void> deleteLocalDatabase() async {
  final dbPath = await getDatabasesPath();
  print("\n\n" + "eliminando en path: " + dbPath );
  final path = join(dbPath, 'db_reciclaje.db');
  await deleteDatabase(path);

  DatabaseService._db = null;
}