import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:flutter/material.dart';

class MaterialForms extends StatefulWidget {
  const MaterialForms({
    super.key,
    required this.materials,
    required this.onTotalChange,
  });

  final List<RecyclingMaterial> materials;
  final bool clampMaxWeightAtCurrentStock = false;
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
    if (materialForms.any(
      (e) => materialForms.any(
        (d) =>
            d.key.currentState!.selectedMaterial ==
                e.key.currentState!.selectedMaterial &&
            d.key != e.key,
      ),
    )) {
      return "Hay materiales repetidos en el ingreso";
    }
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
                                    clampMaxWeightAtCurrentStock:
                                        widget.clampMaxWeightAtCurrentStock,
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
    required this.clampMaxWeightAtCurrentStock,
    required this.onChange,
  });

  final List<RecyclingMaterial> materials;
  final void Function(MaterialForm form) onRemove;
  final int id;
  final bool clampMaxWeightAtCurrentStock;
  final void Function() onChange;

  @override
  State<MaterialForm> createState() => MaterialFormState();
}

class MaterialFormState extends State<MaterialForm> {
  final pesoController = TextEditingController();
  late String selectedMaterial = widget.materials[0].id; // <-- String

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
                child: DropdownMenu<String>(
                  // <-- Especifica tipo String
                  leadingIcon: Icon(Icons.work),
                  onSelected: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedMaterial = value;
                    });
                    widget.onChange();
                  },
                  initialSelection: widget.materials[0].id,
                  label: Text("Material"),
                  dropdownMenuEntries:
                      widget.materials
                          .map(
                            (m) => DropdownMenuEntry<String>(
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
