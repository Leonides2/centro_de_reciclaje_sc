
import 'package:centro_de_reciclaje_sc/core/widgets/widget_field_label.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_title.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_add_ingreso.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_draft_ingreso_details.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_or_ingreso.dart';
import 'package:flutter/material.dart';

class IngresosPage extends StatefulWidget {
  const IngresosPage({super.key});

  @override
  State<IngresosPage> createState() => _IngresosPageState();
}

class _IngresosPageState extends State<IngresosPage> {
  final draftOrIngresoService = DraftOrIngresoService.instance;
  late Future<List<DraftOrIngreso>> _draftIngresos =
      draftOrIngresoService.getDraftOrIngresos();

  void _fetchDraftOrIngresos() {
    _draftIngresos = draftOrIngresoService.getDraftOrIngresos();
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
                  _fetchDraftOrIngresos();
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
              return WaveLoadingAnimation();
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
                    (context, i) => switch (snapshot.data![i]) {
                      DraftIngreso draftIngreso => DraftIngresoCard(
                        draftIngreso,
                      ),
                      Ingreso ingreso => Expanded(child: Placeholder()),
                    },
              ),
            );
          },
        ),
      ],
    );
  }
}

class DraftIngresoCard extends StatelessWidget {
  DraftIngresoCard(this.draftIngreso, {super.key});

  final draftIngresoService = DraftIngresoService.instance;

  final DraftIngreso draftIngreso;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          final entries = await draftIngresoService.getDraftIngresoMaterials(
            draftIngreso.id,
          );

          if (!context.mounted) {
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => DraftIngresoDetailsPage(
                    draftIngreso: draftIngreso,
                    materialEntries: entries,
                  ),
            ),
          );
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
                    : "Pendiente de confirmación de materiales",
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
