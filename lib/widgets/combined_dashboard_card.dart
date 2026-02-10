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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 800;
        final isMobile = width < 600;

        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
                          'Real-Time Monitoring',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Live data from sensors',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
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
                        Row(
                          children: [
                            _buildMetricItem(
                              'Voltage',
                              voltage,
                              Colors.white,
                              Icons.bolt,
                              Colors.amber,
                              isMobile,
                            ),
                            SizedBox(width: isMobile ? 16 : 24),
                            _buildMetricItem(
                              'Current',
                              current,
                              Colors.white,
                              Icons.electrical_services,
                              Colors.redAccent,
                              isMobile,
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        Row(
                          children: [
                            _buildMetricItem(
                              'Power',
                              power,
                              Colors.white,
                              Icons.power,
                              Colors.blue,
                              isMobile,
                            ),
                            SizedBox(width: isMobile ? 16 : 24),
                            _buildMetricItem(
                              'Temperature',
                              temperature,
                              Colors.white,
                              Icons.thermostat,
                              Colors.orange,
                              isMobile,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSmall) SizedBox(height: isMobile ? 24 : 32),
                  // Gauge
                  Expanded(
                    flex: isSmall ? 0 : 2,
                    child: SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              startDegreeOffset: 180,
                              sectionsSpace: 0,
                              centerSpaceRadius: isMobile ? 40 : 50,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.blueAccent,
                                  value: waterLevel,
                                  title: '',
                                  radius: isMobile ? 12 : 16,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  value: 100 - waterLevel,
                                  title: '',
                                  radius: isMobile ? 12 : 16,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: Colors.transparent,
                                  value: 100,
                                  title: '',
                                  radius: isMobile ? 12 : 16,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: isMobile ? 60 : 50,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.blueAccent,
                                  size: isMobile ? 20 : 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${waterLevel.toInt()}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 28 : 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Water Level',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
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
              ),

              const SizedBox(height: 24),
              const Divider(color: Colors.white10),
              const SizedBox(height: 24),

              // Bottom Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBottomStat(
                    'System Status',
                    'Normal',
                    Colors.green,
                    isMobile,
                  ),
                  _buildMetricDivider(),
                  _buildBottomStat(
                    'Active Alerts',
                    '0',
                    Colors.white,
                    isMobile,
                  ),
                  _buildMetricDivider(),
                  _buildBottomStat('Uptime', '24h 12m', Colors.blue, isMobile),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricDivider() {
    return Container(height: 30, width: 1, color: Colors.white10);
  }

  Widget _buildMetricItem(
    String label,
    String value,
    Color valueColor,
    IconData icon,
    Color iconColor,
    bool isMobile,
  ) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: isMobile ? 20 : 24),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStat(
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
            color: Colors.grey,
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
