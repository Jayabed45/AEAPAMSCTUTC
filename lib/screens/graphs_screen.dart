import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/statistic_chart.dart';
import '../widgets/custom_header.dart';

class GraphsScreen extends StatelessWidget {
  const GraphsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: Text('Statistics'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid: 2 columns on mobile, 3 on tablet, 4 on desktop
                  int crossAxisCount = 2;
                  if (constraints.maxWidth > 900) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 3;
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      StatisticChart(
                        title: 'Voltage',
                        unit: '(V)',
                        lineColor: Colors.amber,
                        maxY: 40,
                        spots: const [
                          FlSpot(6, 20),
                          FlSpot(7, 22),
                          FlSpot(8, 28),
                          FlSpot(9, 35),
                          FlSpot(10, 34),
                        ],
                      ),
                      StatisticChart(
                        title: 'Current',
                        unit: '(A)',
                        lineColor: Colors.green,
                        maxY: 6,
                        spots: const [
                          FlSpot(6, 2),
                          FlSpot(7, 3),
                          FlSpot(8, 3),
                          FlSpot(9, 4),
                          FlSpot(10, 3.5),
                        ],
                      ),
                      StatisticChart(
                        title: 'Energy Usage',
                        unit: '',
                        lineColor: Colors.blue,
                        maxY: 0.4,
                        spots: const [
                          FlSpot(6, 0.1),
                          FlSpot(7, 0.12),
                          FlSpot(8, 0.15),
                          FlSpot(9, 0.25),
                          FlSpot(10, 0.22),
                        ],
                      ),
                      StatisticChart(
                        title: 'Water Level',
                        unit: '(%)',
                        lineColor: Colors.cyan,
                        maxY: 60,
                        spots: const [
                          FlSpot(6, 30),
                          FlSpot(7, 31),
                          FlSpot(8, 30),
                          FlSpot(9, 32),
                          FlSpot(10, 33),
                        ],
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
