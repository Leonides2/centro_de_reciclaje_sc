import 'dart:developer';

import 'package:centro_de_reciclaje_sc/core/widgets/widget_field_label.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_title.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_add_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_ingreso.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class IngresosPage extends StatefulWidget {
  const IngresosPage({super.key});

  @override
  State<IngresosPage> createState() => _IngresosPageState();
}

class _IngresosPageState extends State<IngresosPage> {
  final draftIngresoService = DraftIngresoService.instance;
  late Future<List<DraftIngreso>> _draftIngresos =
      draftIngresoService.getDraftIngresos();

  void _fetchDraftIngresos() {
    _draftIngresos = draftIngresoService.getDraftIngresos();
  }

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
              ).then(
                (context) => setState(() {
                  _fetchDraftIngresos();
                }),
              );
            },
            child: Text("Añadir ingreso"),
          ),
        ),
        FutureBuilder(
          future: _draftIngresos,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Expanded(
                child: Center(child: Text("Error: ${snapshot.error}")),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Expanded(
                child: Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
              );
            }

            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Expanded(
                child: Center(
                  child: Text("No se han añadido ingresos al sistema"),
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder:
                    (context, i) => DraftIngresoCard(snapshot.data![i]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class DraftIngresoCard extends StatelessWidget {
  const DraftIngresoCard(this.draftIngreso, {super.key});

  final DraftIngreso draftIngreso;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          log("tap in... ${draftIngreso.id}");
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draftIngreso.detalle.trim(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 22),
              ),
              FieldLabel("Fecha de creación:"),
              Text(
                "${draftIngreso.fechaCreado.day}/${draftIngreso.fechaCreado.month}/${draftIngreso.fechaCreado.year}",
              ),
              Text(
                draftIngreso.confirmado
                    ? "Confirmado"
                    : "Pendiente de confirmación",
                style: TextStyle(
                  color: draftIngreso.confirmado ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
