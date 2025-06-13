import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Widget khusus untuk menampilkan grafik statistik badan
class StatistikBadanChart extends StatelessWidget {
  const StatistikBadanChart({super.key});

  DashboardStatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Di sini Anda akan mengganti data statis ini dengan data dari pengguna Anda
    final List<FlSpot> dummyData = [
      FlSpot(150, 50),
      FlSpot(160, 58),
      FlSpot(170, 65),
      FlSpot(175, 72),
      FlSpot(180, 78),
    ];

    return LineChart(
      LineChartData(
        // Batas sumbu X (Tinggi Badan) dan Y (Berat Badan)
        minX: 0,
        maxX: 200,
        minY: 0,
        maxY: 100,

        // Konfigurasi Garis Judul (Sumbu X dan Y)
        titlesData: FlTitlesData(
          show: true,
          // Judul Sumbu Bawah (Tinggi Badan)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 20, // Kelipatan 20 untuk tinggi badan
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(value.toInt().toString(),
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                );
              },
            ),
          ),
          // Judul Sumbu Kiri (Berat Badan)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 10, // Kelipatan 10 untuk berat badan
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(value.toInt().toString(),
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                );
              },
            ),
          ),
          // Menonaktifkan judul atas dan kanan
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        // Konfigurasi Garis Grid
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          verticalInterval: 20,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: Colors.black12, strokeWidth: 1),
          getDrawingVerticalLine: (value) =>
              const FlLine(color: Colors.black12, strokeWidth: 1),
        ),

        // Konfigurasi Border Grafik
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black26, width: 1),
        ),

        // Data Garis Grafik
        lineBarsData: [
          LineChartBarData(
            spots: dummyData, // Gunakan data Anda di sini
            isCurved: true,
            color: Theme.of(context)
                .primaryColor, // Menggunakan warna utama dari tema Anda
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          )
        ],
      ),
    );
  }
}
