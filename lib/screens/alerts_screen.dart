import 'package:flutter/material.dart';
import '../widgets/alert_tile.dart';
import '../widgets/custom_header.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: Text('Alerts'),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800), // Limit width on large screens
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'ALERTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.more_horiz, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const AlertTile(
                      icon: Icons.water_drop,
                      iconColor: Colors.red,
                      title: 'Water level is low. Take action as soon as possible.',
                      description: '',
                      badgeText: 'Critical',
                      badgeColor: Colors.red,
                      time: '5 minutes ago',
                      subInfoLabel: 'Water Level',
                      subInfoValue: '15%',
                      subInfoValueColor: Colors.red,
                    ),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 12),
                    const AlertTile(
                      icon: Icons.thermostat,
                      iconColor: Colors.orange,
                      title: 'Temperature exceeds safe limit. Reduce load or',
                      description: '',
                      badgeText: 'Warning',
                      badgeColor: Colors.orange,
                      time: '15 minutes ago',
                      subInfoLabel: 'Temperature',
                      subInfoValue: '45.3°C',
                      subInfoValueColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
