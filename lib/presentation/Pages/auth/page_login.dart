import 'dart:math';

import 'package:centro_de_reciclaje_sc/providers/UserProvider.dart';
import 'package:centro_de_reciclaje_sc/services/service_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/images/icon.png', height: 100),
            const SizedBox(height: 20),
            // Título
            const Text(
              'Inicio de sesión',
              style: TextStyle(color: Color(0xFF017d1c), fontSize: 24),
            ),
            const SizedBox(height: 20),
            // Campo de usuario
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: TextStyle(color: Color(0xFF017d1c)),
                hintText: 'Ingrese su correo electrónico',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF017d1c)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              enableSuggestions: true,
              style: const TextStyle(color: Color(0xFF017d1c)),
            ),
            const SizedBox(height: 20),
            // Campo de contraseña
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Color(0xFF017d1c)),
                hintText: 'Ingrese su contraseña',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF017d1c)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    // ignore: dead_code
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFF017d1c),
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword,

              style: const TextStyle(color: Color(0xFF017d1c)),
            ),
            const SizedBox(height: 20),
            // Botón de inicio de sesión
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text;

                final user = await UserService.instance.authenticate(
                  email,
                  password,
                );

                if (user != null) {
                  // Login exitoso
                   Provider.of<UserProvider>(context, listen: false).setUser(user);
                  widget.onLoginSuccess();
                } else {
                  // Login fallido
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Usuario o contraseña incorrectos'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 10),
            // Botón de olvidar contraseña
            TextButton(
              onPressed:
                  null, // Aquí puedes agregar la lógica para olvidar contraseña
              child: const Text(
                'Olvidé mi contraseña',
                style: TextStyle(color: Color(0xFF017d1c)),
              ),
            ),
             TextButton(
              onPressed:
                  widget.onLoginSuccess, // Aquí puedes agregar la lógica para olvidar contraseña
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Color.fromARGB(255, 200, 200,200))
              ),
              child: const Text(
                'O inicie sesión como invitado',
                style: TextStyle(color: Color(0xFF017d1c)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
