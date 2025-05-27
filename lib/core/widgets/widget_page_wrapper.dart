import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  const PageWrapper({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(child: child),
    );
  }
}
