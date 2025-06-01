
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class PdfGenerator {
  static Future<Uint8List> generatePdf(String tipoReporte, DateTime fechaInicio, DateTime fechaFin) async {
    final pdf = pw.Document();
    
    String formatDate(DateTime date) {
      return "${date.day}/${date.month}/${date.year}";
    }

    late String titulo;
    late String descripcion;

    switch (tipoReporte) {
      case 'Materiales':
        titulo = 'Reporte de Materiales';
        descripcion = 'Reciclaje entre ${formatDate(fechaInicio)} y ${formatDate(fechaFin)}.';
        break;
      case 'Ingresos':
        titulo = 'Reporte de Ingresos';
        descripcion = 'Ingresos generados entre ${formatDate(fechaInicio)} y ${formatDate(fechaFin)}.';
        break;
      case 'Usuarios':
        titulo = 'Reporte de Usuarios';
        descripcion = 'Actividad de usuarios entre ${formatDate(fechaInicio)} y ${formatDate(fechaFin)}.';
        break;
      case 'Tendencias':
        titulo = 'Reporte de Tendencias';
        descripcion = 'Análisis del reciclaje entre ${formatDate(fechaInicio)} y ${formatDate(fechaFin)}.';
        break;
      default:
        titulo = 'Reporte Desconocido';
        descripcion = 'No hay datos disponibles.';
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(titulo, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(descripcion, style: pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );

    return await pdf.save();
  }
}

