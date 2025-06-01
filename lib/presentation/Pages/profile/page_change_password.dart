import 'package:centro_de_reciclaje_sc/providers/UserProvider.dart';
import 'package:centro_de_reciclaje_sc/services/service_user.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPassword1Controller = TextEditingController();
  final TextEditingController newPassword2Controller = TextEditingController();

  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPassword1Controller.dispose();
    newPassword2Controller.dispose();
    super.dispose();
  }

  Future<void> _changePassword(String email) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await UserService.instance.changePassword(
        email: email,
        oldPassword: oldPasswordController.text,
        newPassword: newPassword1Controller.text,
      );
      setState(() {
        _message = "¡Contraseña cambiada exitosamente!";
      });
      oldPasswordController.clear();
      newPassword1Controller.clear();
      newPassword2Controller.clear();
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
    final email = user?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambiar contraseña"),
        backgroundColor: const Color(0xFF017d1c),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Icon(Icons.lock, size: 60, color: Color(0xFF017d1c)),
                const SizedBox(height: 20),
                Text(
                  "Usuario: $email",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña actual",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese su contraseña actual";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPassword1Controller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Nueva contraseña",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese una nueva contraseña";
                    }
                    if (value.length < 6) {
                      return "La nueva contraseña debe tener al menos 6 caracteres";
                    }
                    if (value == oldPasswordController.text) {
                      return "La nueva contraseña debe ser diferente a la actual";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPassword2Controller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Repetir nueva contraseña",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Repita la nueva contraseña";
                    }
                    if (value != newPassword1Controller.text) {
                      return "Las contraseñas no coinciden";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Cambiar contraseña"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF017d1c),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _changePassword(email);
                      }
                    },
                  ),
                if (_message != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.startsWith("¡Contraseña cambiada") ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}