import 'package:centro_de_reciclaje_sc/core/widgets/widget_page_wrapper.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_ingresos.dart';
import 'package:flutter/material.dart';

import 'package:centro_de_reciclaje_sc/presentation/Pages/page_materials.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/profile/profile_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageWrapper(child: HomePage()),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0x00017d1c)),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

const materialsPageId = 1;
const ingresosPageId = 3;

class _HomePage extends State<HomePage> {
  int _selectedIndex = 2;

  void _setPageIndex(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_selectedIndex) {
      0 => Placeholder(),
      materialsPageId => MaterialsPage(),
      2 => Placeholder(),
      ingresosPageId => IngresosPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.inventory),label: 'Ingresos',),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _setPageIndex,
      ),
    );
  }
}
