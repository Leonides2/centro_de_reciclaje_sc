
import 'package:flutter/material.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/pdf_generator.dart';
import 'package:printing/printing.dart';

class ReporteDetallePage extends StatefulWidget {
  final String tipoReporte;
  final Color color;
  final IconData icon;

  const ReporteDetallePage({
    super.key,
    required this.tipoReporte,
    required this.color,
    required this.icon,
  });

  @override
  State<ReporteDetallePage> createState() => _ReporteDetallePageState();
}

class _ReporteDetallePageState extends State<ReporteDetallePage> {
  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now();
  DateTime currentMonth = DateTime.now(); // 🔹 Asegura que currentMonth esté definido
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes - ${widget.tipoReporte}'),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opción de reporte del día
            _buildReporteDiaCard(),
            const SizedBox(height: 20),

            // Opción de reporte de fechas específicas
            _buildReporteFechasCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildReporteDiaCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _generarReporteDelDia(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Text',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Generar reporte del día',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReporteFechasCard() {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generar reporte de fechas específicas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // 🔹 Selección de fechas mejorada
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFF017d1c)),
                  label: Text(
                    "Inicio: ${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}",
                    style: const TextStyle(color: Color(0xFF017d1c)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF017d1c)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: fechaInicio,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => fechaInicio = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFF017d1c)),
                  label: Text(
                    "Fin: ${fechaFin.day}/${fechaFin.month}/${fechaFin.year}",
                    style: const TextStyle(color: Color(0xFF017d1c)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF017d1c)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: fechaFin,
                      firstDate: fechaInicio,
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => fechaFin = picked);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botón generar reporte
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _generarReporteFecha(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Generar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMonthSelector() {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              currentMonth = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              currentMonth = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _generarReporteDelDia() {
    final today = DateTime.now();
    final formattedDate = '${today.day}/${today.month}/${today.year}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generando reporte de ${widget.tipoReporte} del día $formattedDate',
        ),
        backgroundColor: widget.color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _generarReporteFecha() async {
     // Validación: mínimo un día de diferencia
  if (fechaFin.difference(fechaInicio).inDays < 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El rango de fechas debe ser de al menos un día de diferencia.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }
    await Printing.layoutPdf(
      onLayout: (format) async => await PdfGenerator.generatePdf(widget.tipoReporte, fechaInicio, fechaFin),
    );
  }
}
