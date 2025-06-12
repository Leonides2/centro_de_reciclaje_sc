import 'package:centro_de_reciclaje_sc/core/format_date.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_egreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/services.dart' show rootBundle;

const String username = 'centroreciclajescapptest@gmail.com';
const String password = 'xmdv mexu txbu pold';

class EmailService {
  static final instance = EmailService();

  Message _createMessage(String recipientEmail, String html, String subject) =>
      Message()
        ..from = Address(username, 'Centro de Reciclaje SC')
        ..recipients.add(Address(recipientEmail))
        ..subject = subject
        ..html = html;

  Future<void> sendIngresoReceipt(
    Ingreso ingreso,
    List<MaterialEntry> entries,
    String recipientEmail,
  ) async {
    final html = await _loadAndFillIngresoTemplate(ingreso, entries);

    final message = _createMessage(
      recipientEmail,
      html,
      "Factura de su venta al Centro de Reciclaje de Santa Cruz del ${formatDateAmPm(ingreso.fechaCreado)}",
    );

    await _sendEmail(message);
  }

  Future<void> sendEgresoReceipt(
    Egreso egreso,
    List<MaterialEntry> entries,
    String recipientEmail,
  ) async {
    final html = await _loadAndFillEgresoTemplate(egreso, entries);

  final message = _createMessage(
    recipientEmail,
    html,
    "Factura de su compra del Centro de Reciclaje de Santa Cruz del ${formatDateAmPm(egreso.fechaCreado)}",
  );

  await _sendEmail(message);
  }

  Future<void> sendPasswordChangeEmail(
  String recipientEmail,
  String nombreUsuario,
  String nuevaContrasena,
) async {
  // Carga la plantilla HTML desde assets
  final template = await rootBundle.loadString('assets/emailTemplates/cambio_passwrd.html');

  // Reemplaza los placeholders
  final html = template
      .replaceAll('{{nombreUsuario}}', nombreUsuario)
      .replaceAll('{{contraseña}}', nuevaContrasena);

  // Crea el mensaje
  final message = _createMessage(
    recipientEmail,
    html,
    "Cambio de contraseña - Centro de Reciclaje SC",
  );

  // Envía el correo
  await _sendEmail(message);
}

  Future<void> _sendEmail(Message message) async {
    final smtpServer = gmail(username, password);

    await send(message, smtpServer, timeout: const Duration(seconds: 40));

    var connection = PersistentConnection(smtpServer);

    await connection.send(message);

    await connection.close();
  }

  Future<String> _loadAndFillIngresoTemplate(
    Ingreso ingreso,
    List<MaterialEntry> entries,
  ) async {
    // Lee la plantilla HTML desde assets
    final template = await rootBundle.loadString('assets/emailTemplates/factura_ingreso.html');

    // Obtén los materiales
    final materials = await MaterialService.instance.getMaterials();

    // Genera las filas de la tabla
    final materialesHtml =
        entries.map((entry) {
          final nombre =
              materials.firstWhere((m) => m.id == entry.idMaterial).nombre;
          return "<tr><td>$nombre</td><td>${entry.peso}</td></tr>";
        }).join();

    // Reemplaza los placeholders
    return template
        .replaceAll('{{nombreVendedor}}', ingreso.nombreVendedor)
        .replaceAll('{{fecha}}', formatDateAmPm(ingreso.fechaCreado))
        .replaceAll('{{detalle}}', ingreso.detalle)
        .replaceAll('{{materiales}}', materialesHtml)
        .replaceAll('{{total}}', ingreso.total.toString());
  }

  Future<String> _loadAndFillEgresoTemplate(
  Egreso egreso,
  List<MaterialEntry> entries,
) async {
  // Lee la plantilla HTML desde assets
   final template = await rootBundle.loadString('assets/emailTemplates/factura_engreso.html');

  // Obtén los materiales
  final materials = await MaterialService.instance.getMaterials();

  // Genera las filas de la tabla
  final materialesHtml = entries.map((entry) {
    final nombre = materials.firstWhere((m) => m.id == entry.idMaterial).nombre;
    return "<tr><td>$nombre</td><td>${entry.peso}</td></tr>";
  }).join();

  // Reemplaza los placeholders
  return template
      .replaceAll('{{nombreCliente}}', egreso.nombreCliente)
      .replaceAll('{{fecha}}', formatDateAmPm(egreso.fechaCreado))
      .replaceAll('{{detalle}}', egreso.detalle)
      .replaceAll('{{materiales}}', materialesHtml)
      .replaceAll('{{total}}', egreso.total.toString());
}
}
