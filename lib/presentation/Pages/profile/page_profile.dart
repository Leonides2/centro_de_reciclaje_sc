
import 'package:centro_de_reciclaje_sc/presentation/UI/ui_button.dart';
import 'package:centro_de_reciclaje_sc/presentation/UI/ui_text_card.dart';
import 'package:centro_de_reciclaje_sc/presentation/UI/ui_text_profile_title.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.onLogout
  });

  final Function onLogout;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 10,
          children: [

            Container(
              color: Color.fromARGB(255, 126, 217, 87),
              height: 160,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 40
                ),
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
                      child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextProfileTitle(
                            text: 'Nombre de usuario',
                            color: Colors.white,
                          ),
                          TextProfileTitle(
                            text: 'email@email.com',
                            color: Color.fromARGB(255, 240, 240, 240)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              ),
            TextCard(text: 'Editar perfil',),
            TextCard(text: 'Cambiar contraseña',),
            UIButton(label: 'Cerrar sesión', onPressed: onLogout)
          ],
        ),
      ),
    );
  }
}



