import 'package:centro_de_reciclaje_sc/providers/UserProvider.dart';
import 'package:centro_de_reciclaje_sc/services/service_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController lastName1Controller;
  late TextEditingController lastName2Controller;
  late TextEditingController profilePictureController;

  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    nameController = TextEditingController(text: user?.name1 ?? "");
    lastName1Controller = TextEditingController(text: user?.lastName1 ?? "");
    lastName2Controller = TextEditingController(text: user?.lastName2 ?? "");
    profilePictureController = TextEditingController(text: user?.profilePictureUrl ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    lastName1Controller.dispose();
    lastName2Controller.dispose();
    profilePictureController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      setState(() {
        _message = "Usuario no encontrado.";
        _loading = false;
      });
      return;
    }
    try {
      await UserService.instance.editUser(
        id: user.id,
        name1: nameController.text.trim(),
        lastName1: lastName1Controller.text.trim(),
        lastName2: lastName2Controller.text.trim(),
        email: user.email, // No se puede editar el correo
        role: user.role ?? "Usuario",
      );
      // Actualiza el provider
      Provider.of<UserProvider>(context, listen: false).setUser(
        user.copyWith(
          name1: nameController.text.trim(),
          lastName1: lastName1Controller.text.trim(),
          lastName2: lastName2Controller.text.trim(),
        ),
      );
      setState(() {
        _message = "¡Perfil actualizado!";
      });
    } catch (e) {
      setState(() {
        _message = "Error: ${e.toString().replaceAll('Exception: ', '')}";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar perfil"),
        backgroundColor: const Color(0xFF017d1c),
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text("No hay usuario autenticado"))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Icon(Icons.person, size: 60, color: Color(0xFF017d1c)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nombre",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Ingrese su nombre" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: lastName1Controller,
                      decoration: const InputDecoration(
                        labelText: "Primer apellido",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: lastName2Controller,
                      decoration: const InputDecoration(
                        labelText: "Segundo apellido",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    /*TextFormField(
                      controller: profilePictureController,
                      decoration: const InputDecoration(
                        labelText: "URL de foto de perfil (opcional)",
                        border: OutlineInputBorder(),
                      ),
                    ),*/
                    const SizedBox(height: 24),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Guardar cambios"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF017d1c),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveProfile();
                          }
                        },
                      ),
                    if (_message != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.startsWith("¡Perfil actualizado") ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ]
                  ],
                ),
              ),
            ),
    );
  }
}