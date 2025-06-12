
import 'package:centro_de_reciclaje_sc/features/Models/model_material.dart';
import 'package:centro_de_reciclaje_sc/services/service_egreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class PdfGenerator {

  static Future<Uint8List> generateMaterialesIngresoReport(DateTime fechaInicio, DateTime fechaFin) async {
    final pdf = pw.Document();

    // 1. Obtener ingresos y materiales
    final ingresos = await IngresoService.instance.getIngresos();
    final materiales = await MaterialService.instance.getMaterials();

    // 2. Filtrar ingresos por fecha
    final ingresosFiltrados = ingresos.where((ingreso) =>
      ingreso.fechaCreado.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
      ingreso.fechaCreado.isBefore(fechaFin.add(const Duration(days: 1)))
    ).toList();

    // 3. Sumar cantidades por material
    final Map<String, num> kilosPorMaterial = {};
    final Map<String, num> montoPorMaterial = {};

    for (final ingreso in ingresosFiltrados) {
      for (final entry in ingreso.materiales) {
        kilosPorMaterial[entry.idMaterial] = (kilosPorMaterial[entry.idMaterial] ?? 0) + entry.peso;

        // Buscar el precio del material en la lista actual (puedes guardar el precio en el ingreso si quieres el histórico)
        final material = materiales.firstWhere((m) => m.id == entry.idMaterial, orElse: () => RecyclingMaterial(id: '', nombre: 'Desconocido', precioKilo: 0, stock: 0));
        montoPorMaterial[entry.idMaterial] = (montoPorMaterial[entry.idMaterial] ?? 0) + (entry.peso * material.precioKilo);
      }
    }

    // 4. Construir el PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reporte de Ingresos de Materiales', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Desde: ${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}  Hasta: ${fechaFin.day}/${fechaFin.month}/${fechaFin.year}', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Material', 'Cantidad (Kg)', 'Monto (₡)'],
              data: kilosPorMaterial.keys.map((id) {
                final material = materiales.firstWhere((m) => m.id == id, orElse: () => RecyclingMaterial(id: '', nombre: 'Desconocido', precioKilo: 0, stock: 0));
                return [
                  material.nombre,
                  kilosPorMaterial[id]?.toStringAsFixed(2) ?? '0',
                  montoPorMaterial[id]?.toStringAsFixed(2) ?? '0',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Total Kg: ${kilosPorMaterial.values.fold<num>(0, (a, b) => a + b).toStringAsFixed(2)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Total ₡: ${montoPorMaterial.values.fold<num>(0, (a, b) => a + b).toStringAsFixed(2)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateIngresosMonetariosReport(DateTime fechaInicio, DateTime fechaFin) async {
  final pdf = pw.Document();

  // 1. Obtener ingresos y egresos
  final ingresos = await IngresoService.instance.getIngresos();
  final egresos = await EgresoService.instance.getEgresos();

  // 2. Filtrar por fecha
  final ingresosFiltrados = ingresos.where((ingreso) =>
    ingreso.fechaCreado.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
    ingreso.fechaCreado.isBefore(fechaFin.add(const Duration(days: 1)))
  ).toList();

  final egresosFiltrados = egresos.where((egreso) =>
    egreso.fechaCreado.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
    egreso.fechaCreado.isBefore(fechaFin.add(const Duration(days: 1)))
  ).toList();

  // 3. Sumar totales
  final totalPagado = ingresosFiltrados.fold<num>(0, (a, b) => a + (b.total ?? 0));
  final totalVendido = egresosFiltrados.fold<num>(0, (a, b) => a + (b.total ?? 0));
  final utilidad = totalVendido - totalPagado;

  // 4. Construir el PDF
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Reporte de Ingresos Monetarios', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Desde: ${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}  Hasta: ${fechaFin.day}/${fechaFin.month}/${fechaFin.year}', style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 16),
          pw.Text('Total vendido (egresos): ₡${totalVendido.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16)),
          pw.Text('Total pagado (ingresos): ₡${totalPagado.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16)),
          pw.Divider(),
          pw.Text('Utilidad: ₡${utilidad.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: utilidad >= 0 ? PdfColor.fromInt(0xFF017d1c) : PdfColor.fromInt(0xFFD32F2F))),
          pw.SizedBox(height: 16),
          pw.Text('Detalle de ventas:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: ['Fecha', 'Cliente', 'Detalle', 'Total (₡)'],
            data: egresosFiltrados.map((e) => [
              "${e.fechaCreado.day}/${e.fechaCreado.month}/${e.fechaCreado.year}",
              e.nombreCliente,
              e.detalle,
              e.total.toStringAsFixed(2),
            ]).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Detalle de compras:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: ['Fecha', 'Vendedor', 'Detalle', 'Total (₡)'],
            data: ingresosFiltrados.map((i) => [
              "${i.fechaCreado.day}/${i.fechaCreado.month}/${i.fechaCreado.year}",
              i.nombreVendedor,
              i.detalle,
              i.total.toStringAsFixed(2),
            ]).toList(),
          ),
        ],
      ),
    ),
  );

  return pdf.save();
}

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

