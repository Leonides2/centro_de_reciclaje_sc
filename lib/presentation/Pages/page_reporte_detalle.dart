import 'package:flutter/material.dart';

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
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();

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
            const SizedBox(height: 16),

            // Selector de mes
            _buildMonthSelector(),
            const SizedBox(height: 16),

            // Calendario
            _buildCalendar(),
            const SizedBox(height: 20),

            // Botón generar
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
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget _buildCalendar() {
    return Column(
      children: [
        // Días de la semana
        Row(
          children:
              ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 8),

        // Días del mes
        ..._buildCalendarWeeks(),
      ],
    );
  }

  List<Widget> _buildCalendarWeeks() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> weeks = [];
    List<Widget> currentWeek = [];

    // Días del mes anterior
    for (int i = 0; i < firstDayWeekday; i++) {
      final day = DateTime(
        currentMonth.year,
        currentMonth.month,
        1 - firstDayWeekday + i,
      );
      currentWeek.add(_buildCalendarDay(day, isCurrentMonth: false));
    }

    // Días del mes actual
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      currentWeek.add(_buildCalendarDay(date, isCurrentMonth: true));

      if (currentWeek.length == 7) {
        weeks.add(Row(children: currentWeek));
        currentWeek = [];
      }
    }

    // Días del mes siguiente
    while (currentWeek.length < 7) {
      final day = DateTime(
        currentMonth.year,
        currentMonth.month + 1,
        currentWeek.length - firstDayWeekday - lastDayOfMonth.day + 1,
      );
      currentWeek.add(_buildCalendarDay(day, isCurrentMonth: false));
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(Row(children: currentWeek));
    }

    return weeks;
  }

  Widget _buildCalendarDay(DateTime date, {required bool isCurrentMonth}) {
    final isSelected =
        selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day;

    return Expanded(
      child: GestureDetector(
        onTap:
            isCurrentMonth
                ? () {
                  setState(() {
                    selectedDate = date;
                  });
                }
                : null,
        child: Container(
          height: 40,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : isCurrentMonth
                        ? Colors.black
                        : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
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

  void _generarReporteFecha() {
    final formattedDate =
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generando reporte de ${widget.tipoReporte} para el $formattedDate',
        ),
        backgroundColor: widget.color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
