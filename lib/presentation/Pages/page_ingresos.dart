import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_title.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_add_ingreso.dart';
import 'package:flutter/material.dart';

class IngresosPage extends StatelessWidget {
  const IngresosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTitle("Ingresos"),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddIngresoPage()),
              );
            },
            child: Text("Añadir ingreso"),
          ),
        ),
      ],
    );
  }
}
