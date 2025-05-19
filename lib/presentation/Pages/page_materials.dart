import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:flutter/material.dart';

import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';

class MaterialsPage extends StatelessWidget {
  MaterialsPage({super.key});

  final materialService = MaterialService.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Title(
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Text("Materiales", textScaler: TextScaler.linear(2.0)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                materialService.registerMaterial("Hierro", 20);
              },
              child: Text("Añadir material"),
            ),
          ],
        ),
        FutureBuilder(
          future: materialService.getMaterials(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Expanded(
                child: Center(child: Text("Error: ${snapshot.error}")),
              );
            }

            if (!snapshot.hasData) {
              return Expanded(child: Center(child: Text("Cargando...")));
            }

            if (snapshot.data!.isEmpty) {
              return Expanded(
                child: Center(
                  child: Text("No se han añadido materiales al sistema"),
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  RecyclingMaterial material = snapshot.data![index];
                  return ListTile(
                    title: Text(
                      "Nombre: ${material.nombre}, Precio/Kilo: ${material.precioKilo}, Stock: ${material.stock} kg",
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class MaterialCard extends StatelessWidget {
  const MaterialCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
