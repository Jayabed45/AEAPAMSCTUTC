import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CombinedChartsSection extends StatefulWidget {
  const CombinedChartsSection({super.key});

  @override
  State<CombinedChartsSection> createState() => _CombinedChartsSectionState();
}

class _CombinedChartsSectionState extends State<CombinedChartsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<FlSpot> voltageSpots = const [
    FlSpot(6, 20),
    FlSpot(7, 22),
    FlSpot(8, 28),
    FlSpot(9, 35),
    FlSpot(10, 34),
  ];

  final List<FlSpot> currentSpots = const [
    FlSpot(6, 2),
    FlSpot(7, 3),
    FlSpot(8, 3),
    FlSpot(9, 4),
    FlSpot(10, 3.5),
  ];

  final List<FlSpot> energySpots = const [
    FlSpot(6, 0.1),
    FlSpot(7, 0.12),
    FlSpot(8, 0.15),
    FlSpot(9, 0.25),
    FlSpot(10, 0.22),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlSpot> _getVisibleSpots(List<FlSpot> allSpots, double animationValue) {
    if (allSpots.isEmpty) return [];

    double minX = allSpots.first.x;
    double maxX = allSpots.last.x;
    double currentX = minX + (maxX - minX) * animationValue;

    List<FlSpot> visibleSpots = [];
    for (int i = 0; i < allSpots.length; i++) {
      if (allSpots[i].x <= currentX) {
        visibleSpots.add(allSpots[i]);
      } else {
        // Interpolate the last spot
        if (i > 0) {
          final p1 = allSpots[i - 1];
          final p2 = allSpots[i];
          final t = (currentX - p1.x) / (p2.x - p1.x);
          final y = p1.y + (p2.y - p1.y) * t;
          visibleSpots.add(FlSpot(currentX, y));
        }
        break;
      }
    }

    // Ensure at least one spot is visible to prevent errors if animation hasn't started well
    if (visibleSpots.isEmpty && allSpots.isNotEmpty) {
      visibleSpots.add(allSpots.first);
    }

    return visibleSpots;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border:
            Theme.of(context).brightness == Brightness.dark
                ? null
                : Border.all(color: Theme.of(context).dividerColor),
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
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LineChart(
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
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.3),
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
                        spots: _getVisibleSpots(voltageSpots, _animation.value),
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
                      // Current (White)
                      LineChartBarData(
                        spots: _getVisibleSpots(currentSpots, _animation.value),
                        isCurved: true,
                        color: Theme.of(context).colorScheme.onSurface,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Energy (Light Yellow)
                      LineChartBarData(
                        spots: _getVisibleSpots(energySpots, _animation.value),
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
                                color:
                                    barSpot.bar.color ??
                                    Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );
              },
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
