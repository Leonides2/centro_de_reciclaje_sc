import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  const PageWrapper({super.key, required this.child, this.appBar});

  final Widget child;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: appBar,
        body: SafeArea(child: child),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0x00017d1c)),
      ),
      /*ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF017D1C),
          onPrimary: Colors.white,
          secondary: Color(0xFFCCF527),
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),*/
    );
  }
}
