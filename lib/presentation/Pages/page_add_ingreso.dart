import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/core/num_format.dart';
import 'package:centro_de_reciclaje_sc/core/show_error_dialog.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_material_forms.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:flutter/material.dart';

class AddIngresoPage extends StatefulWidget {
  const AddIngresoPage({super.key});

  @override
  State<AddIngresoPage> createState() => _AddIngresoPageState();
}

class _AddIngresoPageState extends State<AddIngresoPage> {
  final materialService = MaterialService.instance;
  final draftIngresoService = DraftIngresoService.instance;

  final TextEditingController nombreVendedorController =
      TextEditingController();
  final TextEditingController detalleController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _materialFormsKey = GlobalKey<MaterialFormsState>();

  final ValueNotifier<num> recommendedPrice = ValueNotifier(0.0);

  void _setRecommended(num newRecommended) {
    recommendedPrice.value = newRecommended;
  }

  @override
  void dispose() {
    nombreVendedorController.dispose();
    detalleController.dispose();
    totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(
        title: Text("Añadir Ingreso"),
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
        future: materialService.getMaterials(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaveLoadingAnimation();
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No existen materiales registrados en el sistema. Registre materiales en la página de "Materiales" para comenzar a añadir ingresos.',
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                      child: TextFormField(
                        controller: nombreVendedorController,
                        validator: (value) => validateNotEmpty(value),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          hintText: "Nombre vendedor:",
                          labelText: "Nombre vendedor:",
                        ),
                      ),
                    ),
                    MaterialForms(
                      materials: snapshot.data!,
                      onTotalChange: _setRecommended,
                      key: _materialFormsKey,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ValueListenableBuilder(
                        valueListenable: recommendedPrice,
                        builder:
                            (context, value, child) => Text(
                              "Precio recomendado: ₡${formatNum(value)}",
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        controller: totalController,
                        validator: (value) => validatePrecioStock(value),
                        keyboardType: TextInputType.numberWithOptions(
                          signed: false,
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          prefixText: "₡",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          hintText: "Total:",
                          labelText: "Total:",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        controller: detalleController,
                        validator: (value) => validateNotEmpty(value),
                        keyboardType: TextInputType.multiline,
                        maxLength: 200,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          isDense: true,
                          labelText: "Detalle:",
                          hintText: "Detalle:",
                        ),
                        maxLines: 6,
                        minLines: 2,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        final materialsValidation =
                            _materialFormsKey.currentState!.validateForms();

                        if (materialsValidation != null) {
                          showErrorDialog(context, materialsValidation);
                          return;
                        }

                        await draftIngresoService.registerDraftIngreso(
                          nombreVendedorController.text,
                          num.parse(totalController.text),
                          detalleController.text,
                          _materialFormsKey.currentState!.getFormValues(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text("Añadir ingreso"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
