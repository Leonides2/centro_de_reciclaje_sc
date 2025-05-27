import 'package:flutter/material.dart';

class TextProfileTitle extends StatelessWidget {
  const TextProfileTitle({
    super.key,
    required this.text,
    this.color = const Color.fromARGB(255, 0, 0, 0),
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return 
      Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        overflow: TextOverflow.clip,
      );
  }
}
