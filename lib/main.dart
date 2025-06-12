import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_egresos.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_ingresos.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_materials.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_reportes.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/auth/page_login.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/profile/page_profile.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_users.dart';
import 'package:centro_de_reciclaje_sc/providers/UserProvider.dart';
import 'package:centro_de_reciclaje_sc/services/service_user.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  UserService.instance.ensureAdminUserExists();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MainApp(),
    ),
  );
  //deleteLocalDatabase(); // Eliminar base de datos local para pruebas REMOVER ANTES DE ENTREGAR A PRODUCCIÓN
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

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Página de inicio por defecto

  @override
  Widget build(BuildContext context) {
    
    final user = Provider.of<UserProvider>(context).user;

     final List<Widget> pages = [
      if (user?.role == "Admin") const UsersPage(),
      const MaterialsPage(),
      _buildHomePage(),
      const IngresosPage(),
      const EgresosPage(),
      if (user?.role == "Admin") ReportesPage(),
      ProfilePage(onLogout: widget.onLogout),
    ];


     final List<BottomNavigationBarItem> navItems = [
      if (user?.role == "Admin")
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'Usuarios',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.work),
        label: 'Materiales',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.arrow_downward),
        label: 'Ingresos',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.arrow_upward),
        label: 'Egresos',
      ),
      if (user?.role == "Admin")
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Reportes',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_circle_rounded),
        label: 'Perfil',
      ),
    ];
    // 3. Corrige el índice si cambia el rol (por ejemplo, al cerrar sesión)
    if (_selectedIndex >= pages.length) {
      _selectedIndex = pages.length - 1;
    }

     return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF017d1c),
        unselectedItemColor: Colors.grey,
        items: navItems,
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
  /*
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
  }*/
}
