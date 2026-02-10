import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/combined_dashboard_card.dart';
import '../widgets/custom_header.dart';
import '../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _formattedDate;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _formattedDate = DateFormat(
      'EEEE, MMM d, yyyy, hh:mm a',
    ).format(DateTime.now());
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (mounted) {
      final now = DateTime.now();
      setState(() {
        _formattedDate = DateFormat('EEEE, MMM d, yyyy, hh:mm a').format(now);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHeader(
        height: 80,
        title: Row(
          children: [
            const Icon(Icons.wb_sunny, color: Colors.white, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'PV System Tracker',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'CTU - TC ',
                    style: TextStyle(fontSize: 12, color: AppColors.secondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Bar - Only System Status now
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'System Status',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
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
                  );
                },
              ),
              const SizedBox(height: 24),

              // Main Combo Card with Time
              CombinedDashboardCard(
                title: _formattedDate,
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
                    crossAxisCount = 2;
                    childAspectRatio = 1.0;
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
                        iconColor: Colors.white,
                        value: '0.21 kWh',
                        label: 'Energy Hour',
                        subLabel: 'Water Data',
                        statusText: 'Normal',
                        statusColor: Colors.green,
                      ),
                      DashboardCard(
                        icon: Icons.link,
                        iconColor: Colors.white,
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
