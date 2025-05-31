import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ResetLocalDbPage extends StatelessWidget {
  const ResetLocalDbPage({super.key});

  Future<void> _deleteLocalDatabase(BuildContext context) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'materials.db'); // Cambia el nombre si tu DB se llama diferente
    await deleteDatabase(path);

    // Puedes mostrar un mensaje de éxito
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Base de datos local eliminada. Se sincronizará al volver a abrir las páginas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resetear base de datos local'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.delete_forever),
          label: Text('Borrar base de datos local'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await _deleteLocalDatabase(context);
          },
        ),
      ),
    );
  }
}