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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Overview',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildLegendItem(context, 'Voltage', AppColors.primary),
                      const SizedBox(width: 12),
                      _buildLegendItem(
                        context,
                        'Current',
                        Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      _buildLegendItem(context, 'Energy', AppColors.secondary),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 == 0) {
                          return Text(
                            '${value.toInt()}h',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.3),
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 6,
                maxX: 10,
                minY: 0,
                maxY: 45, // Accommodate max voltage (~35)
                lineBarsData: [
                  // Voltage (Yellow)
                  LineChartBarData(
                    spots: const [
                      FlSpot(6, 20),
                      FlSpot(7, 22),
                      FlSpot(8, 28),
                      FlSpot(9, 35),
                      FlSpot(10, 34),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  // Current (White) - Scaled x5 for visibility?
                  // User asked to combine, but raw values (3-4) will be very low on 0-40 scale.
                  // I will plot raw values as requested, but maybe add a note or separate axis in future.
                  // For now, I will plot raw to be accurate to the data, even if visually small.
                  // Actually, let's stick to raw values to be correct.
                  LineChartBarData(
                    spots: const [
                      FlSpot(6, 2),
                      FlSpot(7, 3),
                      FlSpot(8, 3),
                      FlSpot(9, 4),
                      FlSpot(10, 3.5),
                    ],
                    isCurved: true,
                    color: Theme.of(context).colorScheme.onSurface,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Energy (Light Yellow) - Raw values (0.1-0.2)
                  LineChartBarData(
                    spots: const [
                      FlSpot(6, 0.1),
                      FlSpot(7, 0.12),
                      FlSpot(8, 0.15),
                      FlSpot(9, 0.25),
                      FlSpot(10, 0.22),
                    ],
                    isCurved: true,
                    color: AppColors.secondary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor:
                        (touchedSpot) => Theme.of(context).cardColor,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        String unit = '';
                        Color textColor =
                            barSpot.bar.color ??
                            Theme.of(context).colorScheme.onSurface;

                        // Identify series by color or index
                        if (barSpot.barIndex == 0)
                          unit = 'V';
                        else if (barSpot.barIndex == 1)
                          unit = 'A';
                        else if (barSpot.barIndex == 2)
                          unit = 'kWh';

                        return LineTooltipItem(
                          '${flSpot.y} $unit',
                          TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
