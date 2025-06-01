import 'package:flutter/material.dart';
import 'package:centro_de_reciclaje_sc/presentation/Pages/page_reporte_detalle.dart';
class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();

   
}

class _ReportesPageState extends State<ReportesPage> {
  String selectedModule = 'Materiales'; // 🔹 Por defecto, "Materiales"
  DateTime fechaInicio = DateTime.now().subtract(Duration(days: 30));
  DateTime fechaFin = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Centro de Reportes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
         

            const SizedBox(height: 8),
            const Text(
              'Consulta estadísticas y análisis del centro de reciclaje',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildReportCard(
                    icon: Icons.recycling,
                    title: 'Materiales',
                    subtitle: 'Estadísticas de reciclaje',
                    color: Colors.green,
                  ),
                  _buildReportCard(
                    icon: Icons.attach_money,
                    title: 'Ingresos',
                    subtitle: 'Análisis financiero',
                    color: Colors.blue,
                  ),
                  _buildReportCard(
                    icon: Icons.people,
                    title: 'Usuarios',
                    subtitle: 'Actividad de usuarios',
                    color: Colors.orange,
                  ),
                  _buildReportCard(
                    icon: Icons.trending_up,
                    title: 'Tendencias',
                    subtitle: 'Análisis temporal',
                    color: Colors.purple,
                  ),
                ],
              ),
             ), 

               const SizedBox(height: 20),
        
  //           // 🔹 Seleccionar fechas antes de generar el reporte
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   final DateTime? picked = await showDatePicker(
  //                     context: context,
  //                     initialDate: fechaInicio,
  //                     firstDate: DateTime(2020),
  //                     lastDate: DateTime(2100),
  //                   );
  //                   if (picked != null) setState(() => fechaInicio = picked);
  //                 },
  //                 child: Text("Fecha Inicio"),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   final DateTime? picked = await showDatePicker(
  //                     context: context,
  //                     initialDate: fechaFin,
  //                     firstDate: DateTime(2020),
  //                     lastDate: DateTime(2100),
  //                   );
  //                   if (picked != null) setState(() => fechaFin = picked);
  //                 },
  //                 child: Text("Fecha Fin"),
  //               ),
  //             ],
  //           ),

  //           const SizedBox(height: 20),

  //           // 🔹 Botón para generar el reporte con el módulo y fechas seleccionadas
  //           Center(
  //             child: ElevatedButton(
  //               onPressed: () async {
  //                 await Printing.layoutPdf(
  //                   onLayout: (format) async => await PdfGenerator.generatePdf(selectedModule, fechaInicio, fechaFin),
  //                 );
  //               },
               
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.green[700],
  //                 foregroundColor: Colors.white,
  //                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //              ),
  //               child: Text('Generar Reporte'),
  //             ),
  //           ),
         ],
       ),
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ReporteDetallePage(
                    tipoReporte: title,
                    color: color,
                    icon: icon,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
