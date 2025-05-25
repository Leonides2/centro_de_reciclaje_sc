import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  const PageWrapper({super.key, required this.child, this.appBar});

  final Widget child;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBar,
      body: SafeArea(child: child),
    );
  }
}
