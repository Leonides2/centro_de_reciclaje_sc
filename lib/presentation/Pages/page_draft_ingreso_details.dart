import 'package:centro_de_reciclaje_sc/core/format_date.dart';
import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/core/num_format.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_field_label.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DraftIngresoDetailsPage extends StatelessWidget {
  DraftIngresoDetailsPage({
    super.key,
    required this.draftIngreso,
    required this.materialEntries,
  });

  final DraftIngreso draftIngreso;
  final List<MaterialEntry> materialEntries;
  final _materials = MaterialService.instance.getMaterials();

  final _formKey = GlobalKey<EditMaterialFormsState>();

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(
        title: Text("Detalles del Draft de Ingreso"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      child: FutureBuilder(
        future: _materials,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldLabel("Detalle:"),
                Text(draftIngreso.detalle),
                FieldLabel("Creado el:"),
                Text(formatDateAmPm(draftIngreso.fechaCreado)),
                FieldLabel("Nombre del vendedor:"),
                Text(draftIngreso.nombreVendedor),
                FieldLabel("Materiales:"),
                draftIngreso.confirmado
                    ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: materialEntries.length,
                      itemBuilder:
                          (context, i) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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

                                  Text(
                                    "${formatNum(materialEntries[i].peso)} Kg",
                                  ),
                                ],
                              ),
                            ),
                          ),
                    )
                    : Provider<List<RecyclingMaterial>>.value(
                      value: snapshot.data!,
                      child: EditMaterialForms(
                        key: _formKey,
                        materialEntries: materialEntries,
                      ),
                    ),
                FieldLabel("Total:"),
                Text("₡${formatNum(draftIngreso.total)}"),
                !draftIngreso.confirmado
                    ? Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text("Confirmar materiales"),
                      ),
                    )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EditMaterialForms extends StatefulWidget {
  const EditMaterialForms({super.key, required this.materialEntries});

  final List<MaterialEntry> materialEntries;

  @override
  State<EditMaterialForms> createState() => EditMaterialFormsState();
}

class EditMaterialFormReference {
  const EditMaterialFormReference({required this.form, required this.key});

  final EditMaterialForm form;
  final GlobalKey<EditMaterialFormState> key;
}

class EditMaterialFormsState extends State<EditMaterialForms> {
  late final List<EditMaterialFormReference> forms =
      widget.materialEntries.map((e) {
        final key = GlobalKey<EditMaterialFormState>();
        return EditMaterialFormReference(
          form: EditMaterialForm(e, key: key),
          key: key,
        );
      }).toList();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: forms.length,
        itemBuilder: (context, i) => forms[i].form,
      ),
    );
  }
}

class EditMaterialForm extends StatefulWidget {
  const EditMaterialForm(this.materialEntry, {super.key});

  final MaterialEntry materialEntry;

  @override
  State<StatefulWidget> createState() => EditMaterialFormState();
}

class EditMaterialFormState extends State<EditMaterialForm> {
  final pesoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pesoController.text = widget.materialEntry.peso.toString();
  }

  @override
  void dispose() {
    pesoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materials = context.read<List<RecyclingMaterial>>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 14,
                bottom: 14,
              ),
              child: FieldLabel(
                materials
                    .firstWhere((e) => e.id == widget.materialEntry.idMaterial)
                    .nombre,
              ),
            ),
            SizedBox(
              width: 120,
              child: TextFormField(
                controller: pesoController,
                validator: (value) => validatePrecioStock(value),
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: InputDecoration(
                  suffixText: "Kg",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  hintText: "Peso:",
                  labelText: "Peso:",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
