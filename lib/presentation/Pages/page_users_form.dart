import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/services/service_user.dart';
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
  late TextEditingController passwordController; // Nuevo
  bool _isEditing = false;
  final userService = UserService.instance;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedRole = "Usuario";
    nameController = TextEditingController(text: widget.user.name1);
    lastNameController = TextEditingController(text: widget.user.lastName1);
    lastName1Controller = TextEditingController(text: widget.user.lastName2);
    emailController = TextEditingController(text: widget.user.email);
    passwordController = TextEditingController(); // Nuevo
    _isEditing = widget.isEditing;
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    lastName1Controller.dispose();
    emailController.dispose();
    passwordController.dispose(); // Nuevo
    super.dispose();
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

              // Campos de texto
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

              // Campo de contraseña solo si está en edición
              if (_isEditing)
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Nueva contraseña (opcional)",
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  obscureText: true,
                ),

              SizedBox(height: 20),

              // Selector de Roles (editable solo si _isEditing es true)
              DropdownButton<String>(
                value: _selectedRole,
                items: ["Super Admin", "Admin", "Usuario"]
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: _isEditing
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
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    await userService.editUser(
                      id: widget.user.id,
                      name1: nameController.text,
                      lastName1: lastNameController.text,
                      lastName2: lastName1Controller.text,
                      email: emailController.text,
                      password: passwordController.text.isNotEmpty
                          ? passwordController.text
                          : null, // Solo cambia si se ingresó
                      profilePictureUrl: widget.user.profilePictureUrl,
                    );
                    if (context.mounted) Navigator.pop(context, widget.user);
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