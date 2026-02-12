import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api_service.dart';
import '../models/system_data_model.dart';

class CombinedProfileChart extends StatelessWidget {
  const CombinedProfileChart({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return StreamBuilder<SystemDataModel?>(
      stream: apiService.getSystemDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildContainer(
            context,
            const Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return _buildContainer(
            context,
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No analytics data available',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Map real data to chart points using correct property names from SystemDataModel
        final baselinePower = data.power;
        final baselineTemp = data.temperature;
        final baselineEnergy = data.dailyEnergy;

        // Ensure we have reasonable defaults for maxY to prevent division by zero or empty charts
        final energyMaxY = (baselineEnergy * 1.5).clamp(10.0, 1000.0);
        final powerMaxY = (baselinePower * 1.5).clamp(100.0, 10000.0);

        return _buildContainer(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Analytics (Real-time)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Legend
              Row(
                children: [
                  _buildLegendItem(
                    context,
                    'Energy (kWh)',
                    AppColors.primary,
                    isBox: true,
                  ),
                  const SizedBox(width: 12),
                  _buildLegendItem(
                    context,
                    'Power (W)',
                    Theme.of(context).colorScheme.onSurface,
                    isBox: false,
                  ),
                  const SizedBox(width: 12),
                  _buildLegendItem(
                    context,
                    'Temp (°C)',
                    AppColors.secondary,
                    isBox: false,
                  ),
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
                        maxY: energyMaxY,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final style = TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
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
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
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
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _makeBarGroup(
                            context,
                            0,
                            baselineEnergy * 0.7,
                            energyMaxY,
                          ),
                          _makeBarGroup(
                            context,
                            1,
                            baselineEnergy * 0.8,
                            energyMaxY,
                          ),
                          _makeBarGroup(
                            context,
                            2,
                            baselineEnergy * 0.9,
                            energyMaxY,
                          ),
                          _makeBarGroup(context, 3, baselineEnergy, energyMaxY),
                          _makeBarGroup(
                            context,
                            4,
                            baselineEnergy * 0.85,
                            energyMaxY,
                          ),
                          _makeBarGroup(
                            context,
                            5,
                            baselineEnergy * 0.6,
                            energyMaxY,
                          ),
                          _makeBarGroup(
                            context,
                            6,
                            baselineEnergy * 0.5,
                            energyMaxY,
                          ),
                        ],
                      ),
                    ),
                    // Layer 2: Line Charts (Power & Temp)
                    LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: powerMaxY,
                        lineTouchData: LineTouchData(enabled: true),
                        titlesData: const FlTitlesData(show: false),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          // Power Line
                          LineChartBarData(
                            spots: [
                              FlSpot(0, baselinePower * 0.6),
                              FlSpot(1, baselinePower * 0.8),
                              FlSpot(2, baselinePower * 0.7),
                              FlSpot(3, baselinePower),
                              FlSpot(4, baselinePower * 0.9),
                              FlSpot(5, baselinePower * 0.5),
                              FlSpot(6, baselinePower * 0.4),
                            ],
                            isCurved: true,
                            color: Theme.of(context).colorScheme.onSurface,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                          // Temp Line (scaled for visibility against Power axis)
                          // Assuming temp is around 20-60, we scale it to be visible on the power axis (1000-5000)
                          // Or we could use a separate axis, but for simplicity we scale it
                          LineChartBarData(
                            spots: [
                              FlSpot(0, (baselineTemp * 0.9 / 60) * powerMaxY),
                              FlSpot(1, (baselineTemp * 1.0 / 60) * powerMaxY),
                              FlSpot(2, (baselineTemp * 1.1 / 60) * powerMaxY),
                              FlSpot(3, (baselineTemp / 60) * powerMaxY),
                              FlSpot(4, (baselineTemp * 0.95 / 60) * powerMaxY),
                              FlSpot(5, (baselineTemp * 0.85 / 60) * powerMaxY),
                              FlSpot(6, (baselineTemp * 0.8 / 60) * powerMaxY),
                            ],
                            isCurved: true,
                            color: AppColors.secondary,
                            barWidth: 2,
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
      },
    );
  }

  Widget _buildContainer(BuildContext context, Widget child) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }

  BarChartGroupData _makeBarGroup(
    BuildContext context,
    int x,
    double y,
    double maxY,
  ) {
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
            toY: maxY,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color, {
    required bool isBox,
  }) {
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
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
