import 'package:centro_de_reciclaje_sc/core/num_format.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({super.key});

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  final materialService = MaterialService.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Title(
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Text("Materiales", style: TextStyle(fontSize: 25.0)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddMaterialDialog(
                      onSuccess: () {
                        setState(() {});
                      },
                    );
                  },
                );
              },
              child: Text("Añadir material"),
            ),
          ],
        ),
        FutureBuilder(
          future: materialService.getMaterials(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Expanded(
                child: Center(child: Text("Error: ${snapshot.error}")),
              );
            }

            if (!snapshot.hasData) {
              return Expanded(
                child: Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
              );
            }

            if (snapshot.data!.isEmpty) {
              return Expanded(
                child: Center(
                  child: Text("No se han añadido materiales al sistema"),
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  RecyclingMaterial material = snapshot.data![index];
                  return MaterialCard(
                    material: material,
                    onEditSuccess: () {
                      setState(() {});
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
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
  final TextEditingController textController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final materialService = MaterialService.instance;

  bool _formSubmitted = false;

  @override
  void initState() {
    super.initState();

    textController.addListener(() {
      setState(() {});
    });
    weightController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    textController.dispose();
    weightController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("Nuevo material"),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              labelText: "Nombre:",
              hintText: "Nombre:",
              errorText:
                  _formSubmitted && textController.text.isEmpty
                      ? "Campo requerido"
                      : null,
            ),
            maxLength: 25,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
          child: TextField(
            controller: weightController,
            keyboardType: TextInputType.numberWithOptions(
              signed: false,
              decimal: true,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              labelText: "Precio/Kg",
              hintText: "Precio/Kg:",
              errorText:
                  _formSubmitted && weightController.text.isEmpty
                      ? "Campo requerido"
                      : null,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formSubmitted) {
                      setState(() {
                        _formSubmitted = true;
                      });
                    }
                    if (textController.text.isEmpty ||
                        weightController.text.isEmpty) {
                      return;
                    }

                    materialService.registerMaterial(
                      textController.text,
                      num.parse(weightController.text),
                    );
                    widget.onSuccess();
                    Navigator.pop(context);
                  },
                  child: Text("Añadir"),
                ),
              ),
            ),
          ],
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
    return SimpleDialog(
      title: Text("Detalles:"),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Expanded(
            child: Column(
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cerrar"),
              ),
            ),
            SizedBox(
              width: 120,
              child: ElevatedButton(onPressed: onEdit, child: Text("Editar")),
            ),
          ],
        ),
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

  bool _formSubmitted = false;

  @override
  void initState() {
    super.initState();

    nombreController.addListener(() {
      setState(() {});
    });
    nombreController.text = widget.material.nombre;
    precioController.addListener(() {
      setState(() {});
    });
    precioController.text = widget.material.precioKilo.toString();
    stockController.addListener(() {
      setState(() {});
    });
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
    return SimpleDialog(
      title: Text("Editando \"${widget.material.nombre}\":"),
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: nombreController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              labelText: "Nombre:",
              hintText: "Nombre:",
              errorText:
                  _formSubmitted && nombreController.text.isEmpty
                      ? "Campo requerido"
                      : null,
            ),
            maxLength: 25,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: precioController,
            keyboardType: TextInputType.numberWithOptions(
              signed: false,
              decimal: true,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              labelText: "Precio/Kg",
              hintText: "Precio/Kg:",
              errorText:
                  _formSubmitted && precioController.text.isEmpty
                      ? "Campo requerido"
                      : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: stockController,
            keyboardType: TextInputType.numberWithOptions(
              signed: false,
              decimal: true,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              labelText: "Stock",
              hintText: "Stock:",
              errorText:
                  _formSubmitted && stockController.text.isEmpty
                      ? "Campo requerido"
                      : null,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: widget.onClose,
                child: Text("Cancelar"),
              ),
            ),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  if (!_formSubmitted) {
                    setState(() {
                      _formSubmitted = true;
                    });
                  }
                  if (nombreController.text.isEmpty ||
                      precioController.text.isEmpty ||
                      stockController.text.isEmpty) {
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
                          'Precio: ₡${formatNum(precio)}\n'
                          'Stock: ${formatNum(stock)} Kg\n'
                          'Los cambios no se verán reflejados en el historial de ingresos o egresos. ¿Está seguro?',
                        ),
                        actions: [
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancelar"),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {
                                materialService.editMaterial(
                                  id,
                                  nombre,
                                  precio,
                                  stock,
                                );
                                widget.onSuccess();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text("Aceptar"),
                            ),
                          ),
                        ],
                        actionsAlignment: MainAxisAlignment.spaceAround,
                      );
                    },
                  );
                },
                child: Text("Aceptar"),
              ),
            ),
          ],
        ),
      ],
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
      color: Theme.of(context).primaryColor,
      shadowColor: Theme.of(context).shadowColor,
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Icon(Icons.work, color: Colors.white, size: 35.0),
                  ),
                  Text(
                    material.nombre,
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FloatingActionButton(
                onPressed: () {
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
                child: Icon(Icons.subject),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
