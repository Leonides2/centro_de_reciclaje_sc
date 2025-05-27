import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

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
            Image.asset('assets/images/icon.png' , height: 100),
            const SizedBox(height: 20),
            // Título
            const Text(
              'Inicio de sesión',
              style: TextStyle(color: Color(0xFF017d1c), fontSize: 24),
            ),
            const SizedBox(height: 20),
            // Campo de usuario
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre de usuario',
                labelStyle: TextStyle(color: Color(0xFF017d1c)),
                hintText: 'Ingrese su usuario',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF017d1c)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: const TextStyle(color: Color(0xFF017d1c)),
            ),
            const SizedBox(height: 20),
            // Campo de contraseña
            TextField(
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
                suffixIcon: const Icon(Icons.visibility, color: Color(0xFF017d1c)),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Botón de inicio de sesión
            ElevatedButton(
              onPressed: onLoginSuccess,  
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
              onPressed: null,  
              child: const Text(
                'Olvidé mi contraseña',
                style: TextStyle(color: Color(0xFF017d1c)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
