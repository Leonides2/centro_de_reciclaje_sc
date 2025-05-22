import 'dart:developer';

import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddIngresoPage extends StatefulWidget {
  const AddIngresoPage({super.key});

  @override
  State<AddIngresoPage> createState() => _AddIngresoPageState();
}

class _AddIngresoPageState extends State<AddIngresoPage> {
  final materialService = MaterialService.instance;

  final TextEditingController nombreVendedorController =
      TextEditingController();
  final TextEditingController detalleController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final MaterialForms materialForms = MaterialForms();

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
            return Center(
              child: LoadingAnimationWidget.waveDots(
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            );
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        child: TextFormField(
                          controller: nombreVendedorController,
                          validator: (value) => validateNotEmpty(value),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            hintText: "Nombre vendedor:",
                            labelText: "Nombre vendedor:",
                          ),
                        ),
                      ),
                      materialForms,
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
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
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
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
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                        },
                        child: Text("Añadir ingreso"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MaterialForms extends StatefulWidget {
  const MaterialForms({super.key});

  @override
  State<MaterialForms> createState() => _MaterialFormsState();
}

class _MaterialFormsState extends State<MaterialForms> {
  List<MaterialForm> materials = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Materiales", style: TextStyle(fontSize: 17)),
              IconButton.filled(
                onPressed: () {
                  setState(() {
                    materials.add(MaterialForm());
                  });
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ),
        Builder(
          builder: (context) {
            if (materials.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    'Haga click en "+" para añadir un material al ingreso',
                  ),
                ),
              );
            }

            return Flexible(
              child: ListView.builder(
                itemCount: materials.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  return materials[i];
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class MaterialForm extends StatefulWidget {
  const MaterialForm({super.key});

  @override
  State<MaterialForm> createState() => _MaterialFormState();
}

class _MaterialFormState extends State<MaterialForm> {
  final materialService = MaterialService.instance;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
