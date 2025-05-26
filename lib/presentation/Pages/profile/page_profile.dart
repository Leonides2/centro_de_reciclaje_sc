
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [

            Container(
              color: Color.fromARGB(255, 126, 217, 87),
              height: 50,
              width: double.infinity,
              child: Row(
                children: [
                  Text('Profile Page'),
                ],
              )
              ),
            Container(
              child: Text('Profile Page')
              ),
          ],
        ),
      ),
    );
  }
}