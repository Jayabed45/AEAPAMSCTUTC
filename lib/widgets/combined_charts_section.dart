import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CombinedChartsSection extends StatelessWidget {
  const CombinedChartsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildSingleChart('Voltage (V)', AppColors.primary, 40, [
            const FlSpot(6, 20),
            const FlSpot(7, 22),
            const FlSpot(8, 28),
            const FlSpot(9, 35),
            const FlSpot(10, 34),
          ]),
          const SizedBox(height: 24),
          _buildSingleChart('Current (A)', Colors.white, 6, [
            const FlSpot(6, 2),
            const FlSpot(7, 3),
            const FlSpot(8, 3),
            const FlSpot(9, 4),
            const FlSpot(10, 3.5),
          ]),
          const SizedBox(height: 24),
          _buildSingleChart('Energy (kWh)', AppColors.secondary, 0.4, [
            const FlSpot(6, 0.1),
            const FlSpot(7, 0.12),
            const FlSpot(8, 0.15),
            const FlSpot(9, 0.25),
            const FlSpot(10, 0.22),
          ]),
        ],
      ),
    );
  }

  Widget _buildSingleChart(String title, Color color, double maxY, List<FlSpot> spots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.05),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0) {
                        return Text(
                          '${value.toInt()}h',
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY / 2,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value >= 1 ? value.toInt().toString() : value.toStringAsFixed(1),
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 6,
              maxX: 10,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
