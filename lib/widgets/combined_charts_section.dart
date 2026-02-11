import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../controllers/statistics_controller.dart';

class CombinedChartsSection extends StatefulWidget {
  const CombinedChartsSection({super.key});

  @override
  State<CombinedChartsSection> createState() => _CombinedChartsSectionState();
}

class _CombinedChartsSectionState extends State<CombinedChartsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _touchedIndex;

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

    if (visibleSpots.isEmpty && allSpots.isNotEmpty) {
      visibleSpots.add(allSpots.first);
    }

    return visibleSpots;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsController>(
      builder: (context, statsController, child) {
        final voltageSpots = statsController.getVoltageSpots();
        final currentSpots = statsController.getCurrentSpots();
        final energySpots = statsController.getEnergySpots();

        if (statsController.isLoading) {
          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (voltageSpots.isEmpty) {
          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border:
                  Theme.of(context).brightness == Brightness.dark
                      ? null
                      : Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No data yet',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                          _buildLegendItem(
                            context,
                            'Voltage',
                            AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          _buildLegendItem(
                            context,
                            'Current',
                            Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          _buildLegendItem(
                            context,
                            'Energy',
                            AppColors.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final visibleVoltageSpots = _getVisibleSpots(
                      voltageSpots,
                      _animation.value,
                    );
                    final visibleCurrentSpots = _getVisibleSpots(
                      currentSpots,
                      _animation.value,
                    );
                    final visibleEnergySpots = _getVisibleSpots(
                      energySpots,
                      _animation.value,
                    );

                    final voltageBar = LineChartBarData(
                      spots: visibleVoltageSpots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    );

                    final currentBar = LineChartBarData(
                      spots: visibleCurrentSpots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.onSurface,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    );

                    final energyBar = LineChartBarData(
                      spots: visibleEnergySpots,
                      isCurved: true,
                      color: AppColors.secondary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    );

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
                              interval: 4,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}:00',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.3),
                                    fontSize: 10,
                                  ),
                                );
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.3),
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [voltageBar, currentBar, energyBar],
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor:
                                (touchedSpot) => Theme.of(context).cardColor,
                            tooltipBorderRadius: BorderRadius.circular(8),
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipBorder: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                            getTooltipItems: (
                              List<LineBarSpot> touchedBarSpots,
                            ) {
                              return touchedBarSpots.map((barSpot) {
                                String unit = '';

                                if (barSpot.barIndex == 0) {
                                  unit = 'V';
                                } else if (barSpot.barIndex == 1) {
                                  unit = 'A';
                                } else if (barSpot.barIndex == 2) {
                                  unit = 'kWh';
                                }

                                return LineTooltipItem(
                                  '${barSpot.y.toStringAsFixed(1)} $unit',
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
      },
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
