import 'package:centro_de_reciclaje_sc/core/widgets/widget_field_label.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_add_ingreso.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_draft_ingreso_details.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_ingreso_details.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_ingreso.dart';
import 'package:flutter/material.dart';

class IngresosPage extends StatefulWidget {
  const IngresosPage({super.key});

  @override
  State<IngresosPage> createState() => _IngresosPageState();
}

class _IngresosPageState extends State<IngresosPage> {
  final draftOrIngresoService = DraftOrIngresoService.instance;
  late Future<List<DraftOrIngreso>> _draftIngresos =
      draftOrIngresoService.getDraftOrIngresosFiltered();

  void _fetchDraftOrIngresos() {
    _draftIngresos = draftOrIngresoService.getDraftOrIngresosFiltered();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(
        title: Text("Ingresos"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          ElevatedButton(
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
        ],
      ),
      child: FutureBuilder(
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

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder:
                (context, i) => switch (snapshot.data![i]) {
                  DraftIngreso draftIngreso => DraftIngresoCard(
                    draftIngreso,
                    onSuccess:
                        () => setState(() {
                          _fetchDraftOrIngresos();
                        }),
                  ),
                  Ingreso ingreso => IngresoCard(ingreso, onSuccess: () {}),
                },
          );
        },
      ),
    );
  }
}

class DraftIngresoCard extends StatelessWidget {
  DraftIngresoCard(this.draftIngreso, {required this.onSuccess, super.key});

  final draftIngresoService = DraftIngresoService.instance;

  final VoidCallback onSuccess;
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
          ).then((context) {
            onSuccess();
          });
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

class IngresoCard extends StatelessWidget {
  IngresoCard(this.ingreso, {super.key, required this.onSuccess});
  final ingresoService = IngresoService.instance;
  final draftIngresoService = DraftIngresoService.instance;

  final Ingreso ingreso;
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          final total =
              (await draftIngresoService.getDraftIngreso(
                ingreso.idDraftIngreso,
              )).total;
          final entries = await ingresoService.geIngresoMaterials(ingreso.id);

          if (!context.mounted) {
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => IngresoDetailsPage(
                    ingreso: ingreso,
                    total: total,
                    materialEntries: entries,
                  ),
            ),
          ).then((context) {
            onSuccess();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ingreso.detalle.trim(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 22),
              ),
              FieldLabel("Fecha de creación:"),
              Text(
                "${ingreso.fechaCreado.day}/${ingreso.fechaCreado.month}/${ingreso.fechaCreado.year}",
              ),
              Text("Confirmado", style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}
