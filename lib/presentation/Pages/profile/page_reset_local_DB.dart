import 'package:centro_de_reciclaje_sc/services/service_database.dart';
import 'package:flutter/material.dart';

class ResetLocalDbPage extends StatelessWidget {
  const ResetLocalDbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resetear base de datos local'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Text(
                'Esta acción eliminará la base de datos local y sincronizará los datos al volver a abrir las páginas.'
                '\n\nAsegúrate de que tienes una conexión a internet activa para que la sincronización funcione correctamente.',
                
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.delete_forever, 
                color: Colors.white
                ),
                label: Text('Borrar base de datos local', style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  )),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await deleteLocalDatabase();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}