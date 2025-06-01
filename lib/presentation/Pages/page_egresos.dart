import 'package:centro_de_reciclaje_sc/core/widgets/widget_field_label.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_egreso.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_add_egreso.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_egreso_details.dart';
import 'package:centro_de_reciclaje_sc/services/service_egreso.dart';
import 'package:flutter/material.dart';

class EgresosPage extends StatefulWidget {
  const EgresosPage({super.key});

  @override
  State<EgresosPage> createState() => _EgresosPageState();
}

class _EgresosPageState extends State<EgresosPage> {
  final _egresoService = EgresoService.instance;

  late var _egresos = _egresoService.getEgresos();

  void _fetchEgresos() {
    _egresos = _egresoService.getEgresos();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(
        title: Text("Egresos"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEgresoPage()),
              ).then((context) => {setState(_fetchEgresos)});
            },
            child: Text("Añadir egreso"),
          ),
        ],
      ),
      child: FutureBuilder(
        future: _egresos,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaveLoadingAnimation();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No se han registrado egresos en el sistema. Haga click en "añadir egresos" para comenzar.',
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) => EgresoCard(snapshot.data![i]),
          );
        },
      ),
    );
  }
}

class EgresoCard extends StatelessWidget {
  EgresoCard(this.egreso, {super.key});

  final Egreso egreso;

  final _egresoService = EgresoService.instance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          final entries = await _egresoService.getEgresoMaterials(egreso.id);

          if (!context.mounted) {
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EgresoDetailsPage(
                    egreso: egreso,
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
                egreso.detalle.trim(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 22),
              ),
              FieldLabel("Fecha de creación:"),
              Text(
                "${egreso.fechaCreado.day}/${egreso.fechaCreado.month}/${egreso.fechaCreado.year}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
