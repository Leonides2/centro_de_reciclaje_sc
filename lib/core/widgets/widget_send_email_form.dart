import 'package:centro_de_reciclaje_sc/core/input_validators.dart';
import 'package:centro_de_reciclaje_sc/core/show_error_dialog.dart';
import 'package:centro_de_reciclaje_sc/core/show_loading_dialog.dart';
import 'package:flutter/material.dart';

class SendEmailForm extends StatefulWidget {
  const SendEmailForm({
    super.key,
    required this.sendFunction,
    required this.title,
    required this.sendText,
  });

  final String title;
  final String sendText;

  final Future<void> Function(String email) sendFunction;

  @override
  State<SendEmailForm> createState() => _SendEmailFormState();
}

class _SendEmailFormState extends State<SendEmailForm> {
  final _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.email),
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            autofocus: false,
            validator: validateEmail,
            controller: _emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              hintText: "Correo electrónico:",
              labelText: "Correo electrónico:",
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            if (!context.mounted) {
              return;
            }
            FocusManager.instance.primaryFocus?.unfocus();

            showLoadingDialog(context);

            try {
              await widget.sendFunction(_emailController.text);
              if (!context.mounted) {
                return;
              }

              Navigator.pop(context);
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      icon: Icon(Icons.check),
                      title: Text("La factura fué enviada satisfactoriamente"),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Ok"),
                        ),
                      ],
                    ),
              );
            } catch (e) {
              if (!context.mounted) {
                return;
              }
              Navigator.pop(context);
              showErrorDialog(context, e.toString());
            }
          },
          child: Text(widget.sendText),
        ),
      ],
    );
  }
}
