import 'package:flutter/material.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_users_form.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> users = [
    User(id: 1, name1: "Juan", lastName1: "Pérez", email: "juan@example.com"),
    User(
      id: 2,
      name1: "María",
      lastName1: "Rodríguez",
      email: "maria@example.com",
    ),
  ];

  void _deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = "";
        String lastName1 = "";
        String lastName2 = "";
        String email = "";

        return AlertDialog(
          title: Text("Añadir Usuario"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Nombre"),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Primer apellido"),
                onChanged: (value) => lastName1 = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Segundo apellido"),
                onChanged: (value) => lastName2 = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Correo Electrónico"),
                onChanged: (value) => email = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                _addUser(name, lastName1, lastName2, email);
                Navigator.pop(context);
              },
              child: Text("Añadir"),
            ),
          ],
        );
      },
    );
  }

  void _addUser(String name, String lastName1, String lastName2, String email) {
    setState(() {
      users.add(
        User(
          id: users.length + 1,
          name1: name,
          lastName1: lastName1,
          lastName2: lastName2,
          email: email,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Usuarios"), backgroundColor: Colors.teal),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                leading: CircleAvatar(backgroundColor: Colors.blue),
                title: Text(
                  users[index].name1,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Correo: ${users[index].email}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () async {
                        final updatedUser = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => UserFormPage(
                                  user: users[index],
                                  isEditing: true,
                                ), // 👈 Ahora entra en modo edición
                          ),
                        );

                        if (updatedUser != null) {
                          setState(() {
                            users[index] = updatedUser;
                          });
                        }
                      },
                    ),

                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(index),
                    ),

                    IconButton(
                      icon: Icon(Icons.info, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => UserFormPage(
                                  user: users[index],
                                ), // 👈 Abre detalles en modo solo lectura
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showAddUserDialog,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
