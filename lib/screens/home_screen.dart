import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/dashboard_card.dart';

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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                    Row(
                      children: [
                        const Text(
                          'System Status',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
              ),
              const SizedBox(height: 24),

              // Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  double childAspectRatio;

                  if (constraints.maxWidth > 600) {
                    crossAxisCount = 3;
                    childAspectRatio = 1.3;
                  } else {
                    crossAxisCount =
                        2; // Fallback for very small screens, though user requested 3x3 layout, 3 on mobile is too cramped.
                    childAspectRatio = 1.1;
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 20, // Increased spacing for balance
                    mainAxisSpacing: 20, // Increased spacing for balance
                    childAspectRatio: childAspectRatio,
                    children: const [
                      DashboardCard(
                        icon: Icons.flash_on,
                        iconColor: Colors.amber,
                        value: '34.2 V',
                        label: 'Voltage',
                        subLabel: 'Total Check',
                      ),
                      DashboardCard(
                        icon: Icons.electrical_services,
                        iconColor: Colors.orange,
                        value: '5.8 A',
                        label: 'Current',
                        subLabel: 'Temperature',
                        statusText: 'Normal',
                        statusColor: Colors.green,
                      ),
                      DashboardCard(
                        icon: Icons.power,
                        iconColor: Colors.blue,
                        value: '198.4 W',
                        label: 'Power',
                        subLabel: 'Energy - Save',
                        statusText: 'Normal',
                        statusColor: Colors.green,
                      ),
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
                      DashboardCard(
                        icon: Icons.water_drop,
                        iconColor: Colors.blue,
                        value: '82 %',
                        label: 'Water Level',
                        subLabel: 'Daily Today',
                        statusText: 'Daily',
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
