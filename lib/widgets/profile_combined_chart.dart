import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/system_data_model.dart';
import '../controllers/system_controller.dart';

OverlayEntry? _legendOverlayEntry;

void _toggleLegendOverlayAt(BuildContext context, GlobalKey anchorKey) {
  if (_legendOverlayEntry != null) {
    _legendOverlayEntry!.remove();
    _legendOverlayEntry = null;
    return;
  }
  List<Widget> items(BuildContext ctx) => [
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Water (L)',
          style: TextStyle(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.onSurface,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Power (W)',
          style: TextStyle(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Voltage (V)',
          style: TextStyle(
            color: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.teal,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Energy (kWh)',
          style: TextStyle(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Temp (°C)',
          style: TextStyle(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    ),
  ];
  final overlay = Overlay.of(context);
  final RenderBox? overlayBox =
      overlay.context.findRenderObject() as RenderBox?;
  final RenderBox? anchorBox =
      anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (overlayBox == null || anchorBox == null) return;
  final Offset anchor = anchorBox.localToGlobal(
    Offset.zero,
    ancestor: overlayBox,
  );
  final Size screen = overlayBox.size;
  final double width = screen.width.clamp(0, double.infinity);
  final double panelWidth = width > 360 ? 340 : width - 32;
  double left = anchor.dx + (anchorBox.size.width / 2) - (panelWidth / 2);
  left = left.clamp(16, width - panelWidth - 16);
  double top = anchor.dy - 80;
  top = top.clamp(16, screen.height - 160);
  _legendOverlayEntry = OverlayEntry(
    builder:
        (ctx) => Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Theme.of(ctx).cardColor,
                elevation: 8,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: panelWidth),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: items(ctx),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
  );
  overlay.insert(_legendOverlayEntry!);
}

class CombinedProfileChart extends StatefulWidget {
  const CombinedProfileChart({super.key});
  @override
  State<CombinedProfileChart> createState() => _CombinedProfileChartState();
}

class _CombinedProfileChartState extends State<CombinedProfileChart> {
  @override
  void dispose() {
    if (_legendOverlayEntry != null) {
      _legendOverlayEntry!.remove();
      _legendOverlayEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemController>(
      builder: (context, controller, child) {
        final SystemDataModel? data = controller.systemData;
        if (controller.isLoading && data == null) {
          return _buildContainer(
            context,
            const Center(child: CircularProgressIndicator()),
          );
        }
        if (data == null) {
          return _buildContainer(
            context,
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No analytics data available',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // Live values from current_data (same source as CombinedDashboardCard)
        final baselinePower = data.power;
        final baselineVoltage = data.voltage;
        final baselineTemp = data.temperature;
        final baselineEnergyHour = data.energyHour;
        final baselineWater = data.dailyLiters;

        final powerMaxY = (baselinePower * 1.5).clamp(100.0, 10000.0);
        final waterMaxY = (baselineWater * 1.5).clamp(10.0, 10000.0);
        final voltageMax = baselineVoltage.clamp(1.0, 260.0);
        final energyMax = baselineEnergyHour.clamp(1.0, 1000.0);

        final multipliers = [0.9, 1.0, 1.1, 1.0, 0.95, 0.85, 0.8];

        final iconKey = GlobalKey();
        final double axisReserved =
            MediaQuery.of(context).size.width < 380 ? 72 : 80;
        final double lineLeftPadding = axisReserved + 16;
        final double chartRightPadding =
            MediaQuery.of(context).size.width < 380 ? 8 : 16;
        final double axisLabelFontSize =
            MediaQuery.of(context).size.width < 380 ? 10 : 12;
        final double lineBarWidth =
            MediaQuery.of(context).size.width < 380 ? 2.0 : 3.0;
        return _buildContainer(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'System Analytics (Real-time)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    key: iconKey,
                    icon: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 18,
                    ),
                    onPressed: () => _toggleLegendOverlayAt(context, iconKey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: lineLeftPadding,
                        right: chartRightPadding,
                      ),
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: (multipliers.length - 1).toDouble(),
                          minY: 0,
                          maxY: powerMaxY,
                          clipData: const FlClipData(
                            left: true,
                            top: true,
                            right: true,
                            bottom: true,
                          ),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (spots) {
                                return List.generate(spots.length, (i) {
                                  final s = spots[i];
                                  String label;
                                  String value;
                                  if (i == 0) {
                                    label = 'Power';
                                    value = s.y.toStringAsFixed(0);
                                  } else if (i == 1) {
                                    label = 'Voltage';
                                    value = ((baselineVoltage)).toStringAsFixed(
                                      0,
                                    );
                                  } else if (i == 2) {
                                    label = 'Energy';
                                    value = ((baselineEnergyHour))
                                        .toStringAsFixed(2);
                                  } else {
                                    label = 'Temp';
                                    value = ((baselineTemp)).toStringAsFixed(0);
                                  }
                                  return LineTooltipItem(
                                    '$label: $value',
                                    TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                });
                              },
                            ),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                multipliers.length,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  (baselinePower * multipliers[i]).clamp(
                                    0.0,
                                    powerMaxY,
                                  ),
                                ),
                              ),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.onSurface,
                              barWidth: lineBarWidth,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(
                                multipliers.length,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  ((baselineVoltage / voltageMax) * powerMaxY)
                                      .clamp(0.0, powerMaxY),
                                ),
                              ),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: lineBarWidth,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(
                                multipliers.length,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  ((baselineEnergyHour / energyMax) * powerMaxY)
                                      .clamp(0.0, powerMaxY),
                                ),
                              ),
                              isCurved: true,
                              color: Colors.teal,
                              barWidth: lineBarWidth,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(
                                multipliers.length,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  ((baselineTemp / 60.0) * powerMaxY).clamp(
                                    0.0,
                                    powerMaxY,
                                  ),
                                ),
                              ),
                              isCurved: true,
                              color: AppColors.secondary,
                              barWidth: lineBarWidth,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: waterMaxY,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: axisReserved,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                      fontSize: axisLabelFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.1),
                                strokeWidth: 1,
                              ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          multipliers.length,
                          (i) => _makeBarGroup(
                            context,
                            i,
                            (baselineWater * multipliers[i]).clamp(
                              0.0,
                              waterMaxY,
                            ),
                            waterMaxY,
                            rodWidth:
                                MediaQuery.of(context).size.width < 380
                                    ? 10
                                    : 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContainer(BuildContext context, Widget child) {
    final isNarrow = MediaQuery.of(context).size.width < 380;
    return Container(
      height: isNarrow ? 260 : 300,
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }

  BarChartGroupData _makeBarGroup(
    BuildContext context,
    int x,
    double y,
    double maxY, {
    double? rodWidth,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: rodWidth ?? 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }
}
