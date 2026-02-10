import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CombinedDashboardCard extends StatelessWidget {
  final String voltage;
  final String current;
  final String power;
  final String temperature;
  final double waterLevel; // 0 to 100

  const CombinedDashboardCard({
    super.key,
    required this.voltage,
    required this.current,
    required this.power,
    required this.temperature,
    required this.waterLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Real-Time Monitoring',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Content
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              return Flex(
                direction: isSmall ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: 4 Metrics Grid
                  Expanded(
                    flex: isSmall ? 0 : 3,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildMetricItem(
                              'Voltage',
                              voltage,
                              Colors.white,
                              Icons.flash_on,
                              Colors.amber,
                            ),
                            const SizedBox(width: 24),
                            _buildMetricItem(
                              'Current',
                              current,
                              Colors.redAccent,
                              Icons.electrical_services,
                              Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildMetricItem(
                              'Power',
                              power,
                              Colors.blue,
                              Icons.power,
                              Colors.blue,
                            ),
                            const SizedBox(width: 24),
                            _buildMetricItem(
                              'Temp',
                              temperature,
                              Colors.orange,
                              Icons.thermostat,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSmall) const SizedBox(height: 24),
                  // Right Side: Gauge
                  Expanded(
                    flex: isSmall ? 0 : 2,
                    child: SizedBox(
                      height: 150,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              startDegreeOffset: 180,
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.white,
                                  value: waterLevel,
                                  title: '',
                                  radius: 12,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: Colors.redAccent,
                                  value:
                                      (100 - waterLevel) *
                                      0.3, // Visual decoration
                                  title: '',
                                  radius: 12,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: Colors.orange,
                                  value:
                                      (100 - waterLevel) *
                                      0.3, // Visual decoration
                                  title: '',
                                  radius: 12,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: Colors.blue,
                                  value:
                                      (100 - waterLevel) *
                                      0.4, // Visual decoration
                                  title: '',
                                  radius: 12,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: Colors.transparent,
                                  value: 100, // Bottom half hidden
                                  title: '',
                                  radius: 12,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                          // Custom Gauge Implementation using fl_chart is tricky for semi-circle
                          // Let's use a simpler approach for the visual match:
                          // A simplified visual representation
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Water Level',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${waterLevel.toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Bottom Stats (Inside Card)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomStat('Status', 'Normal', Colors.green),
                _buildBottomStat('Alerts', '0', Colors.white),
                _buildBottomStat('Uptime', '24h', Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    Color valueColor,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}
