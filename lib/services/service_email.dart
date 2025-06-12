import 'package:centro_de_reciclaje_sc/core/format_date.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_egreso.dart';
import 'package:centro_de_reciclaje_sc/features/Models/model_material_entry.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// TODO: Tomar datos de un archivo .env
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
    Ingreso ingreso, // <-- Cambia DraftIngreso por Ingreso
    List<MaterialEntry> entries,
    String recipientEmail,
  ) async {
    final materials = await MaterialService.instance.getMaterials();

    final message = _createMessage(
      recipientEmail,
      '<h2>${ingreso.nombreVendedor}! Esta es la factura de su venta "${ingreso.detalle}"</h2>'
          '<ul>${entries.map((entry) => "${materials.firstWhere((m) => m.id == entry.idMaterial).nombre}: ${entry.peso} Kg").map((s) => "<li>$s</li>").fold("", (a, b) => a + b)}</ul>'
          '<p>Total: ₡${ingreso.total}</p>'
          '<p>Muchas gracias por su aporte al Centro de Reciclaje de Santa Cruz!</p>',
      "Factura de su venta al Centro de Reciclaje de Santa Cruz del ${formatDateAmPm(ingreso.fechaCreado)}",
    );

    await _sendEmail(message);
  }

  Future<void> sendEgresoReceipt(
    Egreso egreso,
    List<MaterialEntry> entries,
    String recipientEmail,
  ) async {
    final materials = await MaterialService.instance.getMaterials();

    final message = _createMessage(
      recipientEmail,
      '<h2>${egreso.nombreCliente}! Esta es la factura de su compra "${egreso.detalle}"</h2>'
          '<ul>${entries.map((entry) => "${materials.firstWhere((m) => m.id == entry.idMaterial).nombre}: ${entry.peso} Kg").map((s) => "<li>$s</li>").fold("", (a, b) => a + b)}</ul>'
          '<p>Total: ₡${egreso.total}</p>'
          '<p>Muchas gracias por su aporte al Centro de Reciclaje de Santa Cruz!</p>',
      "Factura de su compra del Centro de Reciclaje de Santa Cruz del ${formatDateAmPm(egreso.fechaCreado)}",
    );

    await _sendEmail(message);
  }

  Future<void> sendNewPassword(
    String recipientEmail,
    String text,
    String subject,
  ) async {
    final message = EmailService.instance._createMessage(
      recipientEmail,
      text,
      subject,
    );
    await EmailService.instance._sendEmail(message);
  }

  Future<void> _sendEmail(Message message) async {
    final smtpServer = gmail(username, password);

    await send(message, smtpServer, timeout: const Duration(seconds: 40));

    var connection = PersistentConnection(smtpServer);

    await connection.send(message);

    await connection.close();
  }
}
