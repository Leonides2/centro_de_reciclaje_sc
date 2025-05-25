import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Title(
      color: Colors.black,
      child: Center(child: Text(title, style: TextStyle(fontSize: 25.0))),
    );
  }
}
