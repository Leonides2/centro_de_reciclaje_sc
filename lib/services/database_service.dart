import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService();

  DatabaseService();

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
      onCreate:
          (db, version) => {
            db.execute('''
        CREATE TABLE Material (
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          Nombre TEXT NOT NULL,
          PrecioKilo REAL NOT NULL
        );

        CREATE TABLE StockMaterial (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          IdMaterial INTEGER NOT NULL,
          Stock REAL NOT NULL
        );

        CREATE TABLE Ingreso (
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          Detalle TEXT NOT NULL,
          NombreVendedor TEXT NOT NULL,
          FechaCreado TEXT NOT NULL,
          FechaConfirmado TEXT NOT NULL,
        );

        CREATE TABLE MaterialIngreso (
          IdMaterial INTEGER NOT NULL,
          IdIngreso INTEGER NOT NULL,
          Peso REAL NOT NULL
        );

        CREATE TABLE DraftIngreso (
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          Detalle TEXT NOT NULL,
          Total REAL NOT NULL,
          NombreVendedor TEXT NOT NULL,
          FechaCreado TEXT NOT NULL,
          Confirmado INTEGER NOT NULL
        );

        CREATE TABLE MaterialDraftIngreso (
          IdMaterial INTEGER NOT NULL,
          IdDraftIngreso INTEGER NOT NULL,
          Peso REAL NOT NULL
        );

        CREATE TABLE Egreso (
          Id INTEGER PRIMARY KEY AUTOINCREMENT,
          Detalle TEXT NOT NULL,
          Total REAL NOT NULL,
          NombreVendedor TEXT NOT NULL,
          FechaCreado TEXT NOT NULL
        );

        CREATE TABLE MaterialEgreso (
          IdMaterial INTEGER NOT NULL,
          IdEgreso INTEGER NOT NULL,
          Peso REAL NOT NULL
        );
      '''),
          },
    );
    return database;
  }
}
