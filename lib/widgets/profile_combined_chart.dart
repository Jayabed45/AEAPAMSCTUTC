import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CombinedProfileChart extends StatelessWidget {
  const CombinedProfileChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _buildLegendItem('Energy (kWh)', AppColors.primary, isBox: true),
              const SizedBox(width: 12),
              _buildLegendItem('Power (W)', Colors.white, isBox: false),
              const SizedBox(width: 12),
              _buildLegendItem('Temp (°C)', AppColors.secondary, isBox: false),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Stack(
              children: [
                // Layer 1: Bar Chart (Energy)
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 20, // Scale for Energy
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            );
                            String text;
                            switch (value.toInt()) {
                              case 0:
                                text = 'Mon';
                                break;
                              case 1:
                                text = 'Tue';
                                break;
                              case 2:
                                text = 'Wed';
                                break;
                              case 3:
                                text = 'Thu';
                                break;
                              case 4:
                                text = 'Fri';
                                break;
                              case 5:
                                text = 'Sat';
                                break;
                              case 6:
                                text = 'Sun';
                                break;
                              default:
                                return Container();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(text, style: style),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40, // Fixed width for alignment
                          getTitlesWidget: (value, meta) {
                            if (value % 5 != 0) return Container();
                            return Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      // Top reserved size 0
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      // Right reserved size 40 (to match LineChart's right axis)
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Container(),
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5,
                      getDrawingHorizontalLine:
                          (value) => FlLine(
                            color: Colors.white.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _makeBarGroup(0, 12),
                      _makeBarGroup(1, 15),
                      _makeBarGroup(2, 10),
                      _makeBarGroup(3, 16),
                      _makeBarGroup(4, 14),
                      _makeBarGroup(5, 18),
                      _makeBarGroup(6, 11),
                    ],
                  ),
                ),
                // Layer 2: Line Charts (Power & Temp)
                LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 20, // Match BarChart maxY
                    lineTouchData: LineTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      // Bottom reserved size 30 (to match BarChart)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) => Container(),
                        ),
                      ),
                      // Left reserved size 40 (to match BarChart)
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Container(),
                        ),
                      ),
                      // Top reserved size 0
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      // Right reserved size 40 (Visible Scale)
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            // Show scale for Power (x10)
                            if (value % 5 != 0) return Container();
                            return Text(
                              '${(value * 10).toInt()}W',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(
                      show: false,
                    ), // Hide grid (Bar has it)
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Line 1: Power (White) - Scaled / 10
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 12.0), // 120W
                          FlSpot(1, 14.5), // 145W
                          FlSpot(2, 11.0), // 110W
                          FlSpot(3, 18.0), // 180W
                          FlSpot(4, 16.5), // 165W
                          FlSpot(5, 19.0), // 190W
                          FlSpot(6, 13.0), // 130W
                        ],
                        isCurved: true,
                        color: Colors.white,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      // Line 2: Temp (Secondary) - Scaled / 5
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 8.0), // 40C
                          FlSpot(1, 9.0), // 45C
                          FlSpot(2, 8.5), // 42.5C
                          FlSpot(3, 11.0), // 55C
                          FlSpot(4, 10.0), // 50C
                          FlSpot(5, 12.0), // 60C
                          FlSpot(6, 9.5), // 47.5C
                        ],
                        isCurved: true,
                        color: AppColors.secondary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, {required bool isBox}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: isBox ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isBox ? BorderRadius.circular(2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
