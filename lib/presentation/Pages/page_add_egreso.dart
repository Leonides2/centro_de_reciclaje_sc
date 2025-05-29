import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/core/num_format.dart';
import 'package:centro_de_reciclaje_sc/core/show_error_dialog.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_material_forms.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/services/service_egreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:flutter/material.dart';

class AddEgresoPage extends StatefulWidget {
  const AddEgresoPage({super.key});

  @override
  State<AddEgresoPage> createState() => _AddEgresoPageState();
}

class _AddEgresoPageState extends State<AddEgresoPage> {
  final egresoService = EgresoService.instance;

  final _nombreClienteController = TextEditingController();
  final _totalController = TextEditingController();
  final _detalleController = TextEditingController();

  final _recommendedPrice = ValueNotifier<num>(0);

  final _materialFormsKey = GlobalKey<MaterialFormsState>();
  final _formKey = GlobalKey<FormState>();

  final _materials = MaterialService.instance.getMaterials();

  void _setRecommended(num newRecommended) {
    _recommendedPrice.value = newRecommended;
  }

  @override
  void dispose() {
    _nombreClienteController.dispose();
    _detalleController.dispose();
    _totalController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(
        title: Text("Añadir egreso"),
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
        future: _materials,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return WaveLoadingAnimation();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No se han registrado materiales en el sistema. Ingrese materiales en la página "materiales".',
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, left: 8, top: 12),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: TextFormField(
                      controller: _nombreClienteController,
                      validator: validateNotEmpty,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        hintText: "Nombre cliente:",
                        labelText: "Nombre cliente:",
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
                      valueListenable: _recommendedPrice,
                      builder:
                          (context, value, child) =>
                              Text("Precio recomendado: ₡${formatNum(value)}"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      controller: _totalController,
                      validator: validatePrecioStock,
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
                      controller: _detalleController,
                      validator: validateNotEmpty,
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

                      try {
                        await egresoService.registerEgreso(
                          _nombreClienteController.text,
                          num.parse(_totalController.text),
                          _detalleController.text,
                          _materialFormsKey.currentState!.getFormValues(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } on String catch (e) {
                        if (!context.mounted) {
                          return;
                        }
                        showErrorDialog(context, e);
                        return;
                      }
                    },
                    child: Text("Añadir egreso"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
