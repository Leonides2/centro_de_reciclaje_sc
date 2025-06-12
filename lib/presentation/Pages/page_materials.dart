import 'package:centro_de_reciclaje_sc/core/num_format.dart';
import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_field_label.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_wave_loading_animation.dart';
import 'package:centro_de_reciclaje_sc/providers/UserProvider.dart';
import 'package:flutter/material.dart';

import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:provider/provider.dart';

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({super.key});

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  final materialService = MaterialService.instance;

  late Future<List<RecyclingMaterial>> _materials;

  @override
  void initState() {
    super.initState();
    _materials = materialService.getMaterials();
  }

  void _fetchMaterials() {
    _materials = materialService.getMaterials();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return PageWrapper(
      appBar: AppBar(
        title: Text("Materiales"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [

          if (user != null)
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddMaterialDialog(
                    onSuccess: () {
                      setState(() {
                        _fetchMaterials();
                      });
                    },
                  );
                },
              );
            },
            child: Text("Añadir material"),
          ),
        ],
      ),
      child: FutureBuilder(
        future: _materials,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return WaveLoadingAnimation();
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text("No se han añadido materiales al sistema"),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              RecyclingMaterial material = snapshot.data![index];
              return MaterialCard(
                material: material,
                onEditSuccess: () {
                  setState(() {
                    _fetchMaterials();
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AddMaterialDialog extends StatefulWidget {
  const AddMaterialDialog({super.key, required this.onSuccess});

  final void Function() onSuccess;

  @override
  State<AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<AddMaterialDialog> {
  final materialService = MaterialService.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController textController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    weightController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.add),
      title: Text("Nuevo material"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextFormField(
                  controller: textController,
                  validator: (value) => validateNotEmpty(value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    labelText: "Nombre:",
                    hintText: "Nombre:",
                  ),
                  maxLength: 25,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  bottom: 8.0,
                ),
                child: TextFormField(
                  controller: weightController,
                  validator: (value) => validatePrecioStock(value),
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    prefixText: "₡",
                    labelText: "Precio/Kg",
                    hintText: "Precio/Kg:",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancelar"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              await materialService.registerMaterial(
                textController.text,
                num.parse(weightController.text),
              );

              widget.onSuccess();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text("Añadir"),
          ),
        ),
      ],
    );
  }
}

class DetailsEditDialog extends StatefulWidget {
  const DetailsEditDialog({
    super.key,
    required this.material,
    required this.onEditSuccess,
  });

  final RecyclingMaterial material;
  final void Function() onEditSuccess;

  @override
  State<DetailsEditDialog> createState() => _DetailsEditDialogState();
}

class _DetailsEditDialogState extends State<DetailsEditDialog> {
  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    if (isEdit) {
      return EditDialog(
        material: widget.material,
        onSuccess: widget.onEditSuccess,
        onClose: () {
          setState(() {
            isEdit = false;
          });
        },
      );
    } else {
      return DetailsDialog(
        material: widget.material,
        onEdit: () {
          setState(() {
            isEdit = true;
          });
        },
      );
    }
  }
}

class DetailsDialog extends StatelessWidget {
  const DetailsDialog({
    super.key,
    required this.material,
    required this.onEdit,
  });

  final RecyclingMaterial material;
  final void Function() onEdit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.work),
      title: Text("Detalles:"),
      content: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel("Nombre:"),
            Text(material.nombre),
            FieldLabel("Precio:"),
            Text("₡${formatNum(material.precioKilo)}/Kg"),
            FieldLabel("Stock:"),
            Text("${formatNum(material.stock)} Kg"),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cerrar"),
        ),

        ElevatedButton(onPressed: onEdit, child: Text("Editar")),
      ],
    );
  }
}

class EditDialog extends StatefulWidget {
  const EditDialog({
    super.key,
    required this.material,
    required this.onClose,
    required this.onSuccess,
  });

  final RecyclingMaterial material;
  final void Function() onClose;
  final void Function() onSuccess;

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final MaterialService materialService = MaterialService.instance;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    nombreController.text = widget.material.nombre;
    precioController.text = widget.material.precioKilo.toString();
    stockController.text = widget.material.stock.toString();
  }

  @override
  void dispose() {
    nombreController.dispose();
    precioController.dispose();
    stockController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        icon: Icon(Icons.edit),
        title: Text("Editando \"${widget.material.nombre}\":"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: nombreController,
                  validator: (value) => validateNotEmpty(value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    labelText: "Nombre:",
                    hintText: "Nombre:",
                  ),
                  maxLength: 25,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  validator: (value) => validatePrecioStock(value),
                  controller: precioController,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    prefixText: "₡",
                    labelText: "Precio/Kg",
                    hintText: "Precio/Kg:",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  validator: (value) => validatePrecioStock(value),
                  controller: stockController,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    suffixText: "Kg",
                    labelText: "Stock",
                    hintText: "Stock:",
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          ElevatedButton(onPressed: widget.onClose, child: Text("Cancelar")),

          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              final id = widget.material.id;
              final nombre = nombreController.text;
              final precio = num.parse(precioController.text);
              final stock = num.parse(stockController.text);

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("¿Está seguro?"),
                    icon: Icon(Icons.edit),
                    content: Text(
                      'El material "${widget.material.nombre}" será modificado para tener los siguientes datos:\n'
                      'Nombre: $nombre\n'
                      'Precio: ₡${formatNum(precio)}/Kg\n'
                      'Stock: ${formatNum(stock)} Kg\n'
                      'Los cambios no se verán reflejados en el historial de ingresos o egresos. ¿Está seguro?',
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await materialService.editMaterial(
                            id,
                            nombre,
                            precio,
                            stock,
                          );
                          widget.onSuccess();
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                        child: Text("Aceptar"),
                      ),
                    ],
                    actionsAlignment: MainAxisAlignment.spaceAround,
                  );
                },
              );
            },
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}

class MaterialCard extends StatelessWidget {
  const MaterialCard({
    super.key,
    required this.material,
    required this.onEditSuccess,
  });

  final RecyclingMaterial material;
  final void Function() onEditSuccess;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return DetailsEditDialog(
                material: material,
                onEditSuccess: onEditSuccess,
              );
            },
          );
        },
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.work, color: Theme.of(context).primaryColor),
                    Text(material.nombre, style: TextStyle(fontSize: 20.0)),
                  ],
                ),
                Text("${formatNum(material.stock)} Kg en stock"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
