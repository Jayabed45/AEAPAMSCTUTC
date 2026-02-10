import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/combined_dashboard_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMM d, yyyy, hh:mm a').format(now);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.orange, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'CTU Tuburan Solar PV Monitoring System',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Cebu Techno University - Tuburan Campus',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 600;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Flex(
                      direction: isSmall ? Axis.vertical : Axis.horizontal,
                      mainAxisAlignment:
                          isSmall
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment:
                              isSmall
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (isSmall) const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              isSmall
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.end,
                          children: [
                            const Text(
                              'System Status',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    'Normal',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Main Combo Card
              const CombinedDashboardCard(
                voltage: '34.2 V',
                current: '5.8 A',
                power: '198.4 W',
                temperature: '45.3°C',
                waterLevel: 82,
              ),

              const SizedBox(height: 24),

              // Bottom Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  double childAspectRatio;

                  if (constraints.maxWidth > 800) {
                    crossAxisCount = 2;
                    childAspectRatio = 2.5;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                    childAspectRatio = 2.0;
                  } else {
                    crossAxisCount = 1;
                    childAspectRatio = 1.8;
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: childAspectRatio,
                    children: const [
                      DashboardCard(
                        icon: Icons.bolt,
                        iconColor: Colors.blue,
                        value: '0.21 kWh',
                        label: 'Energy Hour',
                        subLabel: 'Water Data',
                        statusText: 'Normal',
                        statusColor: Colors.green,
                      ),
                      DashboardCard(
                        icon: Icons.link,
                        iconColor: Colors.blue,
                        value: '3.68 kWh',
                        label: 'Daily Energy',
                        subLabel: 'Hourly Data',
                        statusText: 'Hourly',
                        statusColor: Colors.green,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
