import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          icon: Icon(Icons.error),
          title: Text("Error"),
          content: Text(errorMessage),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Aceptar"),
            ),
          ],
        ),
  );
}
