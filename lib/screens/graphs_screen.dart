import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../widgets/statistic_chart.dart';
import '../widgets/custom_header.dart';
import '../widgets/combined_charts_section.dart';
import '../constants/app_colors.dart';
import '../controllers/statistics_controller.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(title: Text('Statistics')),
      body: SafeArea(
        child: Consumer<StatisticsController>(
          builder: (context, statsController, child) {
            return RefreshIndicator(
              onRefresh: () async {
                await statsController.reloadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
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
                                maxY: 3500,
                                spots: statsController.getPowerSpots(),
                                isLoading: statsController.isLoading,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatisticChart(
                                title: 'Temperature',
                                unit: '(°C)',
                                lineColor: AppColors.secondary,
                                maxY: 60,
                                spots: statsController.getTemperatureSpots(),
                                isLoading: statsController.isLoading,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
