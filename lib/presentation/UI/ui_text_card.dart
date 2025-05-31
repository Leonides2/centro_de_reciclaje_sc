import 'package:flutter/material.dart';

class TextCard extends StatelessWidget {
  const TextCard({
    super.key,
    required this.text,
    this.onTap, // Hacemos onTap opcional
  });

  final String text;
  final VoidCallback? onTap; // Cambia Function por VoidCallback? para seguridad de tipos

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Llama a onTap si no es null
      child: Container(
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
        child: Text(text),
      ),
    );
  }
}