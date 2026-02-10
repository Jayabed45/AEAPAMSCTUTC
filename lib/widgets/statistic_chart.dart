import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatisticChart extends StatefulWidget {
  final String title;
  final String unit;
  final List<FlSpot> spots;
  final Color lineColor;
  final double maxY;

  const StatisticChart({
    super.key,
    required this.title,
    required this.unit,
    required this.spots,
    required this.lineColor,
    required this.maxY,
  });

  @override
  State<StatisticChart> createState() => _StatisticChartState();
}

class _StatisticChartState extends State<StatisticChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

  @override
  Widget build(BuildContext context) {
    // Calculate range
    double minX = 0;
    double maxX = 0;
    if (widget.spots.isNotEmpty) {
      minX = widget.spots.first.x;
      maxX = widget.spots.last.x;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border:
            Theme.of(context).brightness == Brightness.dark
                ? null
                : Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                widget.unit,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.lineColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final currentX = minX + (maxX - minX) * _animation.value;

                // Filter and interpolate spots
                List<FlSpot> visibleSpots = [];
                for (int i = 0; i < widget.spots.length; i++) {
                  if (widget.spots[i].x <= currentX) {
                    visibleSpots.add(widget.spots[i]);
                  } else {
                    // Interpolate the last spot
                    if (i > 0) {
                      final p1 = widget.spots[i - 1];
                      final p2 = widget.spots[i];
                      final t = (currentX - p1.x) / (p2.x - p1.x);
                      final y = p1.y + (p2.y - p1.y) * t;
                      visibleSpots.add(FlSpot(currentX, y));
                    }
                    break;
                  }
                }

                // If animation hasn't started or no spots, show empty or first
                if (visibleSpots.isEmpty && widget.spots.isNotEmpty) {
                  visibleSpots.add(widget.spots.first);
                }

                return LineChart(
                  LineChartData(
                    minX: minX,
                    maxX: maxX,
                    minY: 0,
                    maxY: widget.maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        );
                      },
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
                            if (value % 3 == 0) {
                              return Text(
                                '${value.toInt()} AM', // Simplified for demo
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: visibleSpots,
                        isCurved: true,
                        color: widget.lineColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: widget.lineColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
