import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_ingresos.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_materials.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_reportes.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/auth/page_login.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/profile/page_profile.dart';

import 'package:flutter/material.dart';

// ... resto del código igual

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isLoggedIn = false;

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _onLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centro de Reciclaje SC',
      home: _isLoggedIn
          ? PageWrapper(child: HomePage( onLogout: _onLogout,))
          : LoginPage(onLoginSuccess: _onLoginSuccess),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF017d1c)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;
  const HomePage({super.key, required this.onLogout});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Constantes para los índices de las páginas
const int usuariosPageId = 0;
const int materialsPageId = 1;
const int homePageId = 2;
const int ingresosPageId = 3;
const int reportesPageId = 4;
const int perfilPageId = 5; // Agregado para el perfil

class _HomePageState extends State<HomePage> {
  int _selectedIndex = homePageId; // Iniciar en Home

  void _setPageIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determinar qué página mostrar según el índice seleccionado
    final Widget body = switch (_selectedIndex) {
      usuariosPageId => _buildPlaceholderPage('Usuarios', Icons.person_add),
      materialsPageId => MaterialsPage(),
      homePageId => _buildHomePage(),
      ingresosPageId => IngresosPage(),
      reportesPageId => ReportesPage(),
      perfilPageId => ProfilePage( onLogout: widget.onLogout,), // Página de perfil
      _ => _buildPlaceholderPage('Página no encontrada', Icons.error),
    };

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _setPageIndex,
        selectedItemColor: const Color(0xFF017d1c),
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Materiales'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory),label: 'Ingresos'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics),label: 'Reportes',),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded),label: 'Perfil',),
        ],
      ),
    );
  }

  // Página de inicio simple
  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Reciclaje SC'),
        backgroundColor: const Color(0xFF017d1c),
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF017d1c),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Centro de Reciclaje Santa Cruz',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.recycling, size: 64, color: Color(0xFF017d1c)),
                    SizedBox(height: 16),
                    Text(
                      'Gestión integral de materiales reciclables',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para páginas que aún no están implementadas
  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF017d1c),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta página está en desarrollo',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
