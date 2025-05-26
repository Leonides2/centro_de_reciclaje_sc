

import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the home page after login
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}