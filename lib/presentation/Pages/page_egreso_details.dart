import 'package:centro_de_reciclaje_sc/core/format_date.dart';
import 'package:centro_de_reciclaje_sc/core/num_format.dart';
import 'package:centro_de_reciclaje_sc/core/show_error_dialog.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_field_label.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_egreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_email.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:flutter/material.dart';

class EgresoDetailsPage extends StatelessWidget {
  EgresoDetailsPage({
    super.key,
    required this.egreso,
    required this.materialEntries,
  });

  final Egreso egreso;
  final List<MaterialEntry> materialEntries;
  final _materialService = MaterialService.instance;

  final _emailService = EmailService.instance;

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(
        title: Text("Detalles del Egreso"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      child: FutureBuilder(
        future: _materialService.getMaterials(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Expanded(
              child: Center(child: Text("Error: ${snapshot.error}")),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaveLoadingAnimation();
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                FieldLabel("Detalle:"),
                Text(egreso.detalle),
                FieldLabel("Creado el:"),
                Text(formatDateAmPm(egreso.fechaCreado)),
                FieldLabel("Nombre del cliente:"),
                Text(egreso.nombreCliente),
                FieldLabel("Materiales:"),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: materialEntries.length,
                  itemBuilder:
                      (context, i) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.work),
                                  FieldLabel(
                                    snapshot.data!
                                        .firstWhere(
                                          (e) =>
                                              e.id ==
                                              materialEntries[i].idMaterial,
                                        )
                                        .nombre,
                                  ),
                                ],
                              ),

                              Text("${formatNum(materialEntries[i].peso)} Kg"),
                            ],
                          ),
                        ),
                      ),
                ),
                FieldLabel("Total:"),
                Text("₡${formatNum(egreso.total)}"),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _emailService.sendEgresoReceipt(
                        egreso,
                        materialEntries,
                        "juanjosecorella2004@gmail.com",
                      );
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      showErrorDialog(context, e.toString());
                    }
                  },
                  child: Text("Generar factura"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
