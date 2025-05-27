import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/core/num_format.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
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
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final materialsValidation =
                              _materialFormsKey.currentState!.validateForms();

                          if (materialsValidation != null) {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    icon: Icon(Icons.error),
                                    title: Text("Error"),
                                    content: Text(materialsValidation),
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Aceptar"),
                                      ),
                                    ],
                                  ),
                            );
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
            ),
          );
        },
      ),
    );
  }
}

class MaterialForms extends StatefulWidget {
  const MaterialForms({
    super.key,
    required this.materials,
    required this.onTotalChange,
  });

  final List<RecyclingMaterial> materials;
  final void Function(num n) onTotalChange;

  @override
  State<MaterialForms> createState() => MaterialFormsState();
}

class MaterialFormReference {
  const MaterialFormReference({required this.form, required this.key});

  final MaterialForm form;
  final GlobalKey<MaterialFormState> key;
}

class MaterialFormsState extends State<MaterialForms> {
  List<MaterialFormReference> materialForms = [];
  int lastId = 0;

  void _removeForm(MaterialForm form) {
    setState(() {
      materialForms.removeWhere((f) => form == f.form);
    });

    _calculateTotal();
  }

  // El resto de la validacion lo hace el Form del padre
  String? validateForms() {
    if (materialForms.isEmpty) return "No hay materiales en el ingreso";
    return null;
  }

  List<MaterialEntry> getFormValues() {
    return materialForms
        .map(
          (formRef) => MaterialEntry(
            idMaterial: formRef.key.currentState!.selectedMaterial,
            peso: num.parse(formRef.key.currentState!.pesoController.text),
          ),
        )
        .toList();
  }

  void _calculateTotal() {
    final total = materialForms
        .map((formRef) {
          final peso = num.tryParse(
            formRef.key.currentState!.pesoController.text,
          );
          if (peso == null) return 0;

          return peso *
              widget.materials
                  .firstWhere(
                    (m) => m.id == formRef.key.currentState!.selectedMaterial,
                  )
                  .precioKilo;
        })
        .fold(0, (num a, num b) => a + b);

    widget.onTotalChange(total);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Materiales", style: TextStyle(fontSize: 17)),
                IconButton.filled(
                  onPressed:
                      widget.materials.isNotEmpty
                          ? () {
                            setState(() {
                              final key = GlobalKey<MaterialFormState>();
                              materialForms.add(
                                MaterialFormReference(
                                  form: MaterialForm(
                                    materials: widget.materials,
                                    id: lastId++,
                                    onRemove: _removeForm,
                                    onChange: _calculateTotal,
                                    key: key,
                                  ),
                                  key: key,
                                ),
                              );
                            });
                          }
                          : null,
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              if (materialForms.isEmpty) {
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
                  itemCount: materialForms.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return materialForms[i].form;
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MaterialForm extends StatefulWidget {
  const MaterialForm({
    super.key,
    required this.materials,
    required this.onRemove,
    required this.id,
    required this.onChange,
  });

  final List<RecyclingMaterial> materials;
  final void Function(MaterialForm form) onRemove;
  final int id;
  final void Function() onChange;

  @override
  State<MaterialForm> createState() => MaterialFormState();
}

class MaterialFormState extends State<MaterialForm> {
  final pesoController = TextEditingController();
  late int selectedMaterial = widget.materials[0].id;

  @override
  void initState() {
    super.initState();
    pesoController.addListener(widget.onChange);
  }

  @override
  void dispose() {
    pesoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 14,
                  bottom: 14,
                ),
                child: DropdownMenu(
                  leadingIcon: Icon(Icons.work),
                  onSelected: (value) {
                    if (value == null) {
                      return;
                    }

                    selectedMaterial = value;
                    widget.onChange();
                  },
                  initialSelection: widget.materials[0].id,
                  label: Text("Material"),
                  dropdownMenuEntries:
                      widget.materials
                          .map(
                            (m) => DropdownMenuEntry(
                              value: m.id,
                              label: m.nombre,
                              leadingIcon: Icon(Icons.work),
                            ),
                          )
                          .toList(),
                ),
              ),
              Expanded(
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
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: IconButton.filled(
                onPressed: () {
                  widget.onRemove(widget);
                },
                icon: Icon(Icons.delete),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
