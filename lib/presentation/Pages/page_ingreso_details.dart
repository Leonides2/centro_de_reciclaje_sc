import 'package:centro_de_reciclaje_sc/core/format_date.dart';
import 'package:centro_de_reciclaje_sc/core/num_format.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_field_label.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_send_email_form.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_email.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:flutter/material.dart';

class IngresoDetailsPage extends StatelessWidget {
  IngresoDetailsPage({
    super.key,
    required this.ingreso,
    required this.materialEntries,
    required this.total,
  });

  final Ingreso ingreso;
  final List<MaterialEntry> materialEntries;
  final num total;
  final _materialService = MaterialService.instance;
  final _emailService = EmailService.instance;
  final _draftIngresoService = DraftIngresoService.instance;

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(
        title: Text("Detalles del Ingreso"),
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
                Text(ingreso.detalle),
                FieldLabel("Creado el:"),
                Text(formatDateAmPm(ingreso.fechaCreado)),
                FieldLabel("Confirmado el:"),
                Text(formatDateAmPm(ingreso.fechaConfirmado)),
                FieldLabel("Nombre del vendedor:"),
                Text(ingreso.nombreVendedor),
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
                Text("₡${formatNum(total)}"),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => SendEmailForm(
                            sendFunction: (email) async {
                              _emailService.sendIngresoReceipt(
                                await _draftIngresoService.getDraftIngreso(
                                  ingreso.id,
                                ),
                                materialEntries,
                                email,
                              );
                            },
                            title:
                                "Ingrese el correo electrónico del recipiente de la factura",
                            sendText: "Enviar factura",
                          ),
                    );
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
