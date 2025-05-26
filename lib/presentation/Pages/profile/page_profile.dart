
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        'Username LastName Role 1',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.clip,
                        ),
                        Text('Profile Page'),
                      ],
                    ),
                  ],
                ),
              )
              ),
            Container(
              height: 60,
              width: double.infinity,
              margin: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
              ),
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 239, 239, 239),
              ),
              child: Text('Editar perfil')
              ),
          ],
        ),
      ),
    );
  }
}