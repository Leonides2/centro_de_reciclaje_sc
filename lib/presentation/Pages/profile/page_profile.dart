import 'package:centro_de_reciclaje_sc/presentation/Pages/profile/page_change_password.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/profile/page_edit_profile.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/profile/page_reset_local_DB.dart';
import 'package:centro_de_reciclaje_sc/presentation/UI/ui_button.dart';
import 'package:centro_de_reciclaje_sc/presentation/UI/ui_text_card.dart';
import 'package:centro_de_reciclaje_sc/presentation/UI/ui_text_profile_title.dart';
import 'package:centro_de_reciclaje_sc/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onLogout});

  final Function onLogout;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Opciones y cabecera
              Column(
                children: [
                  Container(
                    color: Color.fromARGB(255, 126, 217, 87),
                    height: 160,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 40),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.all(10),
                            width: 80,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[700],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextProfileTitle(
                                  text: user?.name1 ?? 'Nombre de usuario',
                                  color: Colors.white,
                                ),
                                TextProfileTitle(
                                  text: user?.email ?? 'email@email.com',
                                  color: Color.fromARGB(255, 240, 240, 240),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (user != null) ...[
                    TextCard(
                      text: 'Editar perfil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                      },
                    ),
                    TextCard(
                      text: 'Cambiar contraseña',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage(),
                          ),
                        );
                      },
                    ),
                  ],
                  TextCard(
                    text: 'Descargar datos de la nube',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResetLocalDbPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // Botón siempre abajo
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: UIButton(
                  label: 'Cerrar sesión',
                  onPressed: () {
                    Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).clearUser();
                    onLogout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
