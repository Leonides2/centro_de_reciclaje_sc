import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_user.dart';

class UserFormPage extends StatefulWidget {
  final User user;
  final bool
  isEditing; // 👈 Agregado para diferenciar entre edición y detalles.

  const UserFormPage({required this.user, this.isEditing = false, super.key});

  @override
  UserFormPageState createState() => UserFormPageState();
}

class UserFormPageState extends State<UserFormPage> {
  late String _selectedRole;
  late TextEditingController nameController;
  late TextEditingController lastNameController;
  late TextEditingController lastName1Controller;
  late TextEditingController emailController;
  bool _isEditing = false; // 👈 Variable interna de edición.

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedRole = "Usuario";
    nameController = TextEditingController(text: widget.user.name1);
    lastNameController = TextEditingController(text: widget.user.lastName1);
    lastName1Controller = TextEditingController(text: widget.user.lastName2);
    emailController = TextEditingController(text: widget.user.email);
    _isEditing =
        widget
            .isEditing; // 👈 Define si la pantalla inicia en edición o solo detalles.
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(
        title: Text(_isEditing ? "Editar Usuario" : "Detalles del Usuario"),
        backgroundColor: Colors.teal,
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
              SizedBox(height: 20),

              // Campos de texto (habilitados solo si _isEditing es true)
              TextFormField(
                controller: nameController,
                validator: validateNotEmpty,
                decoration: InputDecoration(
                  labelText: "Nombre",
                  labelStyle: TextStyle(color: Colors.black87),
                ),
                enabled: _isEditing,
              ),
              TextFormField(
                controller: lastNameController,
                validator: validateNotEmpty,
                decoration: InputDecoration(
                  labelText: "Primer apellido",
                  labelStyle: TextStyle(color: Colors.black87),
                ),
                enabled: _isEditing,
              ),
              TextFormField(
                controller: lastName1Controller,
                validator: validateNotEmpty,
                decoration: InputDecoration(
                  labelText: "Segundo apellido",
                  labelStyle: TextStyle(color: Colors.black87),
                ),
                enabled: _isEditing,
              ),
              TextFormField(
                controller: emailController,
                validator: validateNotEmpty,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  labelStyle: TextStyle(color: Colors.black87),
                ),
                enabled: _isEditing,
              ),

              SizedBox(height: 20),

              // Selector de Roles (editable solo si _isEditing es true)
              DropdownButton<String>(
                value: _selectedRole,
                items:
                    ["Super Admin", "Admin", "Usuario"]
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                onChanged:
                    _isEditing
                        ? (role) {
                          setState(() {
                            _selectedRole = role!;
                          });
                        }
                        : null,
              ),

              SizedBox(height: 20),

              // Botón para guardar cambios cuando está en edición
              if (_isEditing)
                ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    widget.user.name1 = nameController.text;
                    widget.user.lastName1 = lastNameController.text;
                    widget.user.lastName2 = lastName1Controller.text;
                    widget.user.email = emailController.text;
                    Navigator.pop(context, widget.user);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text("Guardar", style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
