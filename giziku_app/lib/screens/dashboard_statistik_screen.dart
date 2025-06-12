import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardStatistikScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dataGizi = [
    {
      'tanggal': DateTime(2025, 5, 10),
      'berat': 21.0,
      'tinggi': 115.0,
      'status': 'Normal',
    },
    {
      'tanggal': DateTime(2025, 4, 12),
      'berat': 18.5,
      'tinggi': 110.0,
      'status': 'Kurang',
    },
    {
      'tanggal': DateTime(2025, 3, 14),
      'berat': 25.2,
      'tinggi': 118.0,
      'status': 'Berlebih',
    },
  ];

  const DashboardStatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Gizi Anak')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Perkembangan Berat Badan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups:
                      dataGizi.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data['berat'],
                              color: Colors.blue,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index >= 0 && index < dataGizi.length) {
                            final date = dataGizi[index]['tanggal'] as DateTime;
                            return Text(
                              '${date.month}/${date.year % 100}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Detail Data Gizi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: dataGizi.length,
                itemBuilder: (context, index) {
                  final data = dataGizi[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        '${data['tanggal'].day}/${data['tanggal'].month}/${data['tanggal'].year}',
                      ),
                      subtitle: Text(
                        'Berat: ${data['berat']} kg, Tinggi: ${data['tinggi']} cm\nStatus: ${data['status']}',
                      ),
                      leading: Icon(
                        Icons.monitor_weight,
                        color:
                            data['status'] == 'Normal'
                                ? Colors.green
                                : data['status'] == 'Kurang'
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
