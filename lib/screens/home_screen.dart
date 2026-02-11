import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/combined_dashboard_card.dart';
import '../widgets/custom_header.dart';
import '../controllers/system_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late String _formattedDate;
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _formattedDate = DateFormat(
      'EEEE, MMM d, yyyy, hh:mm a',
    ).format(DateTime.now());

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

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTime();
    });

    // Load data from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemController>().loadSystemData();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomHeader(
        height: 80,
        title: Row(
          children: [
            Icon(
              Icons.wb_sunny,
              color: Theme.of(context).colorScheme.onSurface,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PV System Tracker',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'CTU - TC ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<SystemController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.systemData == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = controller.systemData;

            return RefreshIndicator(
              onRefresh: () => controller.loadSystemData(),
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
                        // Main Combo Card with Time
                        CombinedDashboardCard(
                          title: _formattedDate,
                          voltage: '${data?.voltage ?? 0.0} V',
                          current: '${data?.current ?? 0.0} A',
                          power: '${data?.power ?? 0.0} W',
                          temperature: '${data?.temperature ?? 0.0}°C',
                          waterLevel: data?.waterLevel.toDouble() ?? 0.0,
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
                              children: [
                                DashboardCard(
                                  icon: Icons.bolt,
                                  iconColor: Colors.white,
                                  value: '${data?.energyHour ?? 0.0} kWh',
                                  label: 'Energy Hour',
                                  subLabel: 'Water Data',
                                  statusText: data?.status ?? 'Normal',
                                  statusColor: Colors.green,
                                ),
                                DashboardCard(
                                  icon: Icons.link,
                                  iconColor: Colors.white,
                                  value: '${data?.dailyEnergy ?? 0.0} kWh',
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
              ),
            );
          },
        ),
      ),
    );
  }
}
