import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:centro_de_reciclaje_sc/services/service_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_egreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_user.dart';
import 'package:flutter/material.dart';

class ResetLocalDbPage extends StatelessWidget {
  const ResetLocalDbPage({super.key});

  Future<void> _forceRefreshFirebase(BuildContext context) async {
    // Limpia los caches de los servicios principales
    MaterialService.instance.clearMaterialsCache();
    IngresoService.instance.clearIngresosCache.call();
    EgresoService.instance.clearEgresosCache.call();
    DraftIngresoService.instance.clearDraftIngresosCache.call();

    await MaterialService.instance.getMaterials();
    await UserService.instance.getUsers();
    await IngresoService.instance.getIngresos();
    await EgresoService.instance.getEgresos();
    await DraftIngresoService.instance.getDraftIngresos();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Datos actualizados desde Firebase!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar datos desde Firebase'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Esta acción forzará la recarga de los datos desde la base de datos en la nube (Firebase).'
                '\n\nAsegúrate de tener conexión a internet para obtener los datos más recientes.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.cloud_sync, color: Colors.white),
                label: Text(
                  'Actualizar datos desde Firebase',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () async {
                  await _forceRefreshFirebase(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}