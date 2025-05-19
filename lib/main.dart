import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: HomePage()),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0x00017d1c),
          brightness: Brightness.light,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_selectedIndex) {
      0 => Placeholder(),
      1 => Center(child: Text("Materiales")),
      2 => Placeholder(),
      3 => Placeholder(),
      5 => Placeholder(),
      _ => Placeholder(),
    };

    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Centro de Reciclaje SC"))),
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
            icon: Icon(Icons.description),
            label: 'Historial',
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
