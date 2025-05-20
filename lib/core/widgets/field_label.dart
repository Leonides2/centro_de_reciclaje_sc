import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 19.0));
  }
}
