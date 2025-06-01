import 'package:centro_de_reciclaje_sc/services/service_user.dart';
import 'package:flutter/material.dart';

class GetNewPasswordPage extends StatefulWidget {
  const GetNewPasswordPage({super.key});

  @override
  State<GetNewPasswordPage> createState() => _GetNewPasswordPageState();
}

class _GetNewPasswordPageState extends State<GetNewPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendNewPassword() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await UserService.instance.resetPasswordAndSendEmail(emailController.text.trim());
      setState(() {
        _message = "¡Se ha enviado una nueva contraseña a tu correo!";
      });
    } catch (e) {
      setState(() {
        _message = "No se pudo enviar el correo: ${e.toString().replaceAll('Exception: ', '')}";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text("Recuperar contraseña"),
        backgroundColor: const Color(0xFF017d1c),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_reset, size: 60, color: Color(0xFF017d1c)),
                const SizedBox(height: 20),
                const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(fontSize: 22, color: Color(0xFF017d1c), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Ingresa tu correo electrónico y te enviaremos una nueva contraseña.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese su correo";
                    }
                    if (!value.contains('@')) {
                      return "Correo inválido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_loading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("Enviar nueva contraseña"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF017d1c),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _sendNewPassword();
                      }
                    },
                  ),
                if (_message != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.startsWith("¡Se ha enviado") ? Colors.green : Colors.red,
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