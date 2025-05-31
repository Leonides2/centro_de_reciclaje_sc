import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_egresos.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_ingresos.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_materials.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_reportes.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/auth/page_login.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/profile/page_profile.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_users.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home:
          _isLoggedIn
              ? PageWrapper(child: HomePage(onLogout: _onLogout))
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

const int usuariosPageId = 0;
const int materialsPageId = 1;
const int homePageId = 2;
const int ingresosPageId = 3;
const int egresosPageId = 4;
const int reportesPageId = 5;
const int perfilPageId = 6;

class _HomePageState extends State<HomePage> {
  int _selectedIndex = homePageId; // Iniciar en Home

  void _setPageIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_selectedIndex) {
      usuariosPageId => const UsersPage(),
      materialsPageId => MaterialsPage(),
      homePageId => _buildHomePage(),
      ingresosPageId => IngresosPage(),
      egresosPageId => EgresosPage(),
      reportesPageId => ReportesPage(),
      perfilPageId => ProfilePage(onLogout: widget.onLogout),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Materiales'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_downward),
            label: 'Ingresos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward),
            label: 'Egresos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // Página de inicio simple
  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Reciclaje SC'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
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
