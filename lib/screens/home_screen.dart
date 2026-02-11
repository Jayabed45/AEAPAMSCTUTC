import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/system_data_model.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/combined_dashboard_card.dart';
import '../widgets/custom_header.dart';
import '../controllers/system_controller.dart';
import '../services/api_service.dart';

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

  void _showInsertDataDialog(BuildContext context) {
    final voltageController = TextEditingController(text: '220.0');
    final currentController = TextEditingController(text: '5.0');
    final powerController = TextEditingController(text: '1100.0');
    final tempController = TextEditingController(text: '30.0');
    final waterController = TextEditingController(text: '75');
    final energyHourController = TextEditingController(text: '1.2');
    final dailyEnergyController = TextEditingController(text: '15.5');
    final statusController = TextEditingController(text: 'Normal');
    final hourController = TextEditingController(
      text: DateTime.now().hour.toString(),
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 500),
              margin: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Insert System Data',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(hourController, 'Hour (0-23)'),
                    _buildTextField(voltageController, 'Voltage (V)'),
                    _buildTextField(currentController, 'Current (A)'),
                    _buildTextField(powerController, 'Power (W)'),
                    _buildTextField(tempController, 'Temperature (°C)'),
                    _buildTextField(waterController, 'Water Level (%)'),
                    _buildTextField(energyHourController, 'Energy Hour (kWh)'),
                    _buildTextField(
                      dailyEnergyController,
                      'Daily Energy (kWh)',
                    ),
                    _buildTextField(statusController, 'Status'),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            try {
                              await context
                                  .read<SystemController>()
                                  .generateFullDayData();
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Generated data for 6 AM - 6 PM!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Full Day'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            try {
                              final warningData = SystemDataModel(
                                voltage: 265.0,
                                current: 8.5,
                                power: 2252.5,
                                temperature: 52.5,
                                waterLevel: 8,
                                energyHour: 2.5,
                                dailyEnergy: 25.0,
                                status: 'Warning',
                              );
                              await context.read<SystemController>().updateData(
                                warningData,
                              );

                              final apiService = ApiService();
                              await apiService.addNotification(
                                title: 'Critical Temperature Alert',
                                description:
                                    'System temperature has reached 52.5°C. Immediate attention required!',
                                iconName: 'thermostat_rounded',
                                iconColorHex: '#F44336',
                              );
                              await apiService.addNotification(
                                title: 'Critical Water Level',
                                description:
                                    'Water level is extremely low (8%). System shutdown imminent.',
                                iconName: 'water_drop_rounded',
                                iconColorHex: '#F44336',
                              );
                              await apiService.addNotification(
                                title: 'Overvoltage Alert',
                                description: 'Voltage surge detected: 265.0V.',
                                iconName: 'bolt',
                                iconColorHex: '#F44336',
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Warning data and alerts inserted!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Alert Data'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final newData = SystemDataModel(
                              voltage:
                                  double.tryParse(voltageController.text) ??
                                  0.0,
                              current:
                                  double.tryParse(currentController.text) ??
                                  0.0,
                              power:
                                  double.tryParse(powerController.text) ?? 0.0,
                              temperature:
                                  double.tryParse(tempController.text) ?? 0.0,
                              waterLevel:
                                  int.tryParse(waterController.text) ?? 0,
                              energyHour:
                                  double.tryParse(energyHourController.text) ??
                                  0.0,
                              dailyEnergy:
                                  double.tryParse(dailyEnergyController.text) ??
                                  0.0,
                              status: statusController.text,
                            );

                            try {
                              final selectedHour =
                                  int.tryParse(hourController.text) ??
                                  DateTime.now().hour;
                              final now = DateTime.now();
                              final customTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                selectedHour,
                              );
                              await context.read<SystemController>().updateData(
                                newData,
                                customTimestamp: customTime,
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Data inserted successfully!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Save Data'),
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
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType:
            label == 'Status' ? TextInputType.text : TextInputType.number,
      ),
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInsertDataDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_chart),
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
                          voltage:
                              '${data?.voltage.toStringAsFixed(1) ?? 0.0} V',
                          current:
                              '${data?.current.toStringAsFixed(1) ?? 0.0} A',
                          power: '${data?.power.toStringAsFixed(1) ?? 0.0} W',
                          temperature:
                              '${data?.temperature.toStringAsFixed(1) ?? 0.0}°C',
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
                                  value:
                                      '${data?.energyHour.toStringAsFixed(1) ?? 0.0} kWh',
                                  label: 'Energy Hour',
                                  subLabel: 'Water Data',
                                  statusText: data?.status ?? 'Normal',
                                  statusColor: Colors.green,
                                ),
                                DashboardCard(
                                  icon: Icons.link,
                                  iconColor: Colors.white,
                                  value:
                                      '${data?.dailyEnergy.toStringAsFixed(1) ?? 0.0} kWh',
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
