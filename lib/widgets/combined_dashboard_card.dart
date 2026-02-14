import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';

class CombinedDashboardCard extends StatelessWidget {
  final String voltage;
  final String current;
  final String power;
  final String temperature;
  final double dailyLiters;
  final String title;

  const CombinedDashboardCard({
    super.key,
    required this.voltage,
    required this.current,
    required this.power,
    required this.temperature,
    required this.dailyLiters,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 800;
        final isMobile = width < 600;

        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border:
                Theme.of(context).brightness == Brightness.dark
                    ? null
                    : Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-Time Monitoring',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: isMobile ? 10 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 24 : 32),

              // Main Content
              Flex(
                direction: isSmall ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metrics
                  Expanded(
                    flex: isSmall ? 0 : 3,
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) {
                            final double v = _extractNumber(voltage);
                            final double c = _extractNumber(current);
                            final double p = _extractNumber(power);
                            final double t = _extractNumber(temperature);
                            final Color defaultColor =
                                Theme.of(context).colorScheme.onSurface;
                            final Color voltageColor =
                                v > 250.0 ? Colors.red : defaultColor;
                            final Color currentColor =
                                c >= 5.0 ? Colors.red : defaultColor;
                            final Color powerColor =
                                p >= 300.0 ? Colors.red : defaultColor;
                            final Color temperatureColor =
                                t > 50.0 ? Colors.red : defaultColor;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    _buildMetricItem(
                                      context,
                                      'Voltage',
                                      voltage,
                                      voltageColor,
                                      Icons.bolt,
                                      isMobile,
                                    ),
                                    SizedBox(width: isMobile ? 16 : 24),
                                    _buildMetricItem(
                                      context,
                                      'Current',
                                      current,
                                      currentColor,
                                      Icons.electrical_services,
                                      isMobile,
                                    ),
                                  ],
                                ),
                                SizedBox(height: isMobile ? 24 : 32),
                                Row(
                                  children: [
                                    _buildMetricItem(
                                      context,
                                      'Power',
                                      power,
                                      powerColor,
                                      Icons.power,
                                      isMobile,
                                    ),
                                    SizedBox(width: isMobile ? 16 : 24),
                                    _buildMetricItem(
                                      context,
                                      'Temperature',
                                      temperature,
                                      temperatureColor,
                                      Icons.thermostat,
                                      isMobile,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (isSmall) SizedBox(height: isMobile ? 24 : 32),
                  // Gauge
                  Expanded(
                    flex: isSmall ? 0 : 2,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: dailyLiters),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedLiters, child) {
                        // For the gauge, let's assume a target of 500L per day for visualization
                        // You can adjust this threshold as needed
                        const double targetLiters = 500.0;
                        final double percentage =
                            (animatedLiters / targetLiters * 100).clamp(0, 100);

                        return SizedBox(
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  startDegreeOffset: 180,
                                  sectionsSpace: 0,
                                  centerSpaceRadius: isMobile ? 65 : 70,
                                  sections: [
                                    PieChartSectionData(
                                      color: AppColors.primary,
                                      value: percentage,
                                      title: '',
                                      radius: isMobile ? 20 : 25,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      value: 100 - percentage,
                                      title: '',
                                      radius: isMobile ? 20 : 25,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.transparent,
                                      value: 100,
                                      title: '',
                                      radius: isMobile ? 20 : 25,
                                      showTitle: false,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: isMobile ? 70 : 60,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.water_drop,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      size: isMobile ? 24 : 28,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${animatedLiters.toStringAsFixed(1)}L',
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                        fontSize: isMobile ? 32 : 42,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Daily Liters',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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

              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 24),

              // Bottom Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBottomStat(
                    context,
                    'System Status',
                    'Normal',
                    Colors.green,
                    isMobile,
                  ),
                  _buildMetricDivider(context),
                  _buildBottomStat(
                    context,
                    'Active Alerts',
                    '0',
                    Theme.of(context).colorScheme.onSurface,
                    isMobile,
                  ),
                  _buildMetricDivider(context),
                  _buildBottomStat(
                    context,
                    'Uptime',
                    '24h 12m',
                    Theme.of(context).colorScheme.onSurface,
                    isMobile,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricDivider(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
    IconData icon,
    bool isMobile,
  ) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface,
              size: isMobile ? 20 : 24,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _extractNumber(value)),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, child) {
                    return Text(
                      _formatValue(animatedValue, value),
                      style: TextStyle(
                        color: valueColor,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _extractNumber(String value) {
    final match = RegExp(r'([\d\.]+)').firstMatch(value);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }
    return 0.0;
  }

  String _formatValue(double value, String original) {
    final match = RegExp(r'([\d\.]+)').firstMatch(original);
    if (match == null) return original;
    final numStr = match.group(1)!;
    int decimals = 0;
    if (numStr.contains('.')) {
      decimals = numStr.split('.')[1].length;
    }
    final prefix = original.substring(0, match.start);
    final suffix = original.substring(match.end);
    return '$prefix${value.toStringAsFixed(decimals)}$suffix';
  }

  Widget _buildBottomStat(
    BuildContext context,
    String label,
    String value,
    Color color,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: isMobile ? 10 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
