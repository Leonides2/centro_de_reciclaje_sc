import 'package:centro_de_reciclaje_sc/presentation/Pages/page_ingresos.dart';
import 'package:flutter/material.dart';

import 'package:centro_de_reciclaje_sc/presentation/Pages/page_materials.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(child: HomePage()),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0x00017d1c)),
      ),
      /*ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF017D1C),
          onPrimary: Colors.white,
          secondary: Color(0xFFCCF527),
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),*/
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _selectedIndex = 2;

  void _onItemTapped(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_selectedIndex) {
      0 => Placeholder(),
      1 => MaterialsPage(),
      2 => Placeholder(),
      3 => IngresosPage(),
      5 => Placeholder(),
      _ => Placeholder(),
    };

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Materiales'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Ingresos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
