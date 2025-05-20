import 'package:centro_de_reciclaje_sc/core/num_format.dart';
import 'package:flutter/material.dart';
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
                  return MaterialCard(material);
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

  final Function onSuccess;

  @override
  State<AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<AddMaterialDialog> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final materialService = MaterialService.instance;

  bool _formSubmitted = false;

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
                    if (textController.text.isEmpty ||
                        weightController.text.isEmpty) {
                      setState(() {
                        _formSubmitted = true;
                      });
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

class MaterialCard extends StatelessWidget {
  const MaterialCard(this.material, {super.key});

  final RecyclingMaterial material;

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
                    "${material.nombre} ₡${formatNum(material.precioKilo)}/Kg",
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FloatingActionButton(
                onPressed: () {},
                child: Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
