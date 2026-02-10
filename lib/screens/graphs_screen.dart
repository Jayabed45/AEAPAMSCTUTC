import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/statistic_chart.dart';
import '../widgets/custom_header.dart';
import '../widgets/combined_charts_section.dart';
import '../constants/app_colors.dart';

class GraphsScreen extends StatelessWidget {
  const GraphsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(title: Text('Statistics')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CombinedChartsSection(),
              const SizedBox(height: 24),

              // Top Row: Power and Temperature
              Row(
                children: [
                  Expanded(
                    child: StatisticChart(
                      title: 'Power Output',
                      unit: '(W)',
                      lineColor: AppColors.primary,
                      maxY: 150,
                      spots: const [
                        FlSpot(6, 40),
                        FlSpot(7, 66),
                        FlSpot(8, 84),
                        FlSpot(9, 140),
                        FlSpot(10, 119),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatisticChart(
                      title: 'Temperature',
                      unit: '(°C)',
                      lineColor: AppColors.secondary,
                      maxY: 60,
                      spots: const [
                        FlSpot(6, 25),
                        FlSpot(7, 28),
                        FlSpot(8, 32),
                        FlSpot(9, 45),
                        FlSpot(10, 42),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bottom: Water Level (Full Width)
              StatisticChart(
                title: 'Water Level',
                unit: '(%)',
                lineColor: Colors.white,
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
          ),
        ),
      ),
    );
  }
}
