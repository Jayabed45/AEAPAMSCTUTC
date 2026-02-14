import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';
import '../widgets/notification_item.dart';
import '../widgets/custom_header.dart';
import '../widgets/confirmation_modal.dart';
import '../widgets/status_modal.dart';
import '../constants/app_colors.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../controllers/system_controller.dart';

class AlertsScreen extends StatefulWidget {
  final ValueChanged<String>? onSectionChanged;
  const AlertsScreen({super.key, this.onSectionChanged});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ApiService _apiService = ApiService();
  final List<Map<String, dynamic>> _exportedPdfs = [];
  Timer? _dailyExportTimer;

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyEntry(
    BuildContext context, {
    required String time,
    required String voltage,
    required String water,
    required String energy,
    required String temp,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  context,
                  'Voltage',
                  voltage,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatChip(
                  context,
                  'Water',
                  water,
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  context,
                  'Energy',
                  energy,
                  Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatChip(
                  context,
                  'Temp',
                  temp,
                  Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportedPdfItem(
    BuildContext context, {
    required String path,
    required DateTime time,
  }) {
    final theme = Theme.of(context);
    final fileName = path.split(Platform.pathSeparator).last;
    final dateStr =
        '${time.year.toString().padLeft(4, '0')}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () async {
        await OpenFilex.open(path);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.dividerColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fileName,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr $timeStr',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                await _downloadAndNotify(context, path);
              },
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download',
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _recordExport(String path) {
    _exportedPdfs.insert(0, {'path': path, 'time': DateTime.now()});
    setState(() {});
  }

  Future<String> _downloadPdfToUserDownloads(String srcPath) async {
    final srcFile = File(srcPath);
    if (!await srcFile.exists()) throw Exception('Source file not found');
    final fileName = srcPath.split(Platform.pathSeparator).last;
    Directory? destDir;
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final downloads = await getDownloadsDirectory();
        destDir = downloads ?? await getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        final publicDownloads = Directory('/storage/emulated/0/Download');
        destDir =
            await publicDownloads.exists()
                ? publicDownloads
                : await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        destDir = await getApplicationDocumentsDirectory();
      } else {
        destDir = await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      destDir = await getApplicationDocumentsDirectory();
    }
    String destPath = '${destDir.path}${Platform.pathSeparator}$fileName';
    File destFile = File(destPath);
    if (await destFile.exists()) {
      final dot = destPath.lastIndexOf('.');
      final base = dot > 0 ? destPath.substring(0, dot) : destPath;
      final ext = dot > 0 ? destPath.substring(dot) : '';
      int i = 1;
      while (await destFile.exists()) {
        destPath = '${base} ($i)$ext';
        destFile = File(destPath);
        i++;
      }
    }
    await srcFile.copy(destPath);
    return destFile.path;
  }

  Future<void> _downloadAndNotify(BuildContext context, String srcPath) async {
    try {
      final savedPath = await _downloadPdfToUserDownloads(srcPath);
      showDialog(
        context: context,
        builder:
            (context) => StatusModal(
              type: StatusType.success,
              title: 'Download Complete',
              message: savedPath,
            ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => StatusModal(
              type: StatusType.error,
              title: 'Download Failed',
              message: '$e',
            ),
      );
    }
  }

  Future<void> _uploadPdfToFirebase(
    String path, {
    required Map<String, double> summary,
    required String type,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('PDF file not found');
    }
    final now = DateTime.now();
    final fileName = path.split(Platform.pathSeparator).last;
    final month = now.month.toString().padLeft(2, '0');
    final storagePath = 'reports/${now.year}-$month/$fileName';
    final storage = FirebaseStorage.instanceFor(
      bucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
    );
    final ref = storage.ref().child(storagePath);
    final snapshot = await ref.putFile(
      file,
      SettableMetadata(contentType: 'application/pdf'),
    );
    if (snapshot.state != TaskState.success) {
      throw Exception('Upload failed');
    }
    final url = await ref.getDownloadURL();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection('reports').add({
      'fileName': fileName,
      'url': url,
      'storagePath': storagePath,
      'createdAt': Timestamp.fromDate(now),
      'type': type,
      'summary': {
        'vAvg': summary['vAvg'] ?? 0,
        'vMax': summary['vMax'] ?? 0,
        'tAvg': summary['tAvg'] ?? 0,
        'tMin': summary['tMin'] ?? 0,
        'tMax': summary['tMax'] ?? 0,
        'liters': summary['liters'] ?? 0,
        'energy': summary['energy'] ?? 0,
      },
      'userId': uid,
    });
  }

  Future<String> _generateAndSaveDailyPdf(
    List<Map<String, dynamic>> todays, {
    required Map<String, double> summary,
    String filePrefix = 'Manual_Report',
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    final doc = pw.Document();

    final headerStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );
    final subHeaderStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
    );
    final bodyStyle = pw.TextStyle(fontSize: 11);

    pw.MemoryImage? logoImage;
    try {
      final bytes = await rootBundle.load('assets/images/ic_launcher.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      logoImage = null;
    }

    pw.Widget buildSummaryRow(String label, String value) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: subHeaderStyle),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 14)),
          ],
        ),
      );
    }

    final rows =
        todays.map((d) {
          DateTime? dt;
          final ts = d['timestamp'];
          if (ts is Timestamp) {
            dt = ts.toDate();
          }
          String timeStr =
              dt != null
                  ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                  : '--:--';
          double voltage = (d['voltage'] ?? 0).toDouble();
          double current = (d['current'] ?? 0).toDouble();
          double power = (d['power'] ?? 0).toDouble();
          double temperature = (d['temperature'] ?? 0).toDouble();
          double liters = (d['dailyLiters'] ?? 0).toDouble();
          double energyHour = (d['energyHour'] ?? 0).toDouble();
          double dailyEnergy = (d['dailyEnergy'] ?? 0).toDouble();
          String status = (d['status'] ?? '').toString();

          return [
            timeStr,
            voltage.toStringAsFixed(1),
            current.toStringAsFixed(2),
            power.toStringAsFixed(1),
            temperature.toStringAsFixed(1),
            liters.toStringAsFixed(0),
            energyHour.toStringAsFixed(2),
            dailyEnergy.toStringAsFixed(2),
            status.isEmpty ? '-' : status,
          ];
        }).toList();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(margin: const pw.EdgeInsets.all(24)),
        build:
            (context) => [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoImage != null)
                    pw.Container(
                      width: 36,
                      height: 36,
                      margin: const pw.EdgeInsets.only(right: 12),
                      child: pw.Image(logoImage),
                    ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PHOTOVOLTAIC ARRAY MONITORING SYSTEM',
                          style: headerStyle,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Report', style: bodyStyle),
                            pw.Text(dateStr, style: bodyStyle),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Column(
                children: [
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: buildSummaryRow(
                          'Voltage Avg',
                          '${(summary['vAvg'] ?? 0).toStringAsFixed(1)} V',
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: buildSummaryRow(
                          'Temp Avg',
                          '${(summary['tAvg'] ?? 0).toStringAsFixed(1)} °C',
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: buildSummaryRow(
                          'Water Usage',
                          '${(summary['liters'] ?? 0).toStringAsFixed(0)} L',
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: buildSummaryRow(
                          'Energy Daily',
                          '${(summary['energy'] ?? 0).toStringAsFixed(1)} kWh',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: buildSummaryRow(
                      'Voltage Max',
                      '${(summary['vMax'] ?? 0).toStringAsFixed(1)} V',
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: buildSummaryRow(
                      'Temp Min / Max',
                      '${(summary['tMin'] ?? 0).toStringAsFixed(1)}°C / ${(summary['tMax'] ?? 0).toStringAsFixed(1)}°C',
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Hourly Details', style: subHeaderStyle),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Time',
                  'Voltage (V)',
                  'Current (A)',
                  'Power (W)',
                  'Temp (°C)',
                  'Water (L)',
                  'Energy (kWh/hr)',
                  'Daily Energy (kWh)',
                  'Status',
                ],
                data: rows,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
                headerStyle: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: bodyStyle,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.centerRight,
                  7: pw.Alignment.centerRight,
                  8: pw.Alignment.centerLeft,
                },
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.2),
                  1: const pw.FlexColumnWidth(1.1),
                  2: const pw.FlexColumnWidth(1.1),
                  3: const pw.FlexColumnWidth(1.1),
                  4: const pw.FlexColumnWidth(1.1),
                  5: const pw.FlexColumnWidth(1.0),
                  6: const pw.FlexColumnWidth(1.2),
                  7: const pw.FlexColumnWidth(1.2),
                  8: const pw.FlexColumnWidth(1.4),
                },
              ),
            ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${filePrefix}_${dateStr}_$timeStr.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await doc.save());
    return filePath;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().loadNotifications();
      final controller = DefaultTabController.of(context);
      widget.onSectionChanged?.call('Notifications');
      controller.addListener(() {
        final index = controller.index;
        final label = index == 0 ? 'Notifications' : 'Report';
        widget.onSectionChanged?.call(label);
      });
      _scheduleDailyAutoExport();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dailyExportTimer?.cancel();
    super.dispose();
  }

  void _scheduleDailyAutoExport() {
    final now = DateTime.now();
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final duration = nextMidnight.difference(now);
    _dailyExportTimer?.cancel();
    _dailyExportTimer = Timer(duration, () async {
      if (!mounted) return;
      final day = DateTime(now.year, now.month, now.day);
      await _autoExportForDay(day);
      _scheduleDailyAutoExport();
    });
  }

  Future<void> _autoExportForDay(DateTime day) async {
    try {
      final start = DateTime(day.year, day.month, day.day, 0, 0, 0);
      final end = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
      final qs =
          await FirebaseFirestore.instance
              .collection('system_history')
              .where(
                'timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(start),
              )
              .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
              .orderBy('timestamp')
              .get();
      final entries = qs.docs.map((d) => d.data()).toList();
      if (entries.isEmpty) return;
      double vSum = 0, tSum = 0;
      int count = 0;
      double maxLiters = 0, maxEnergy = 0;
      double vMax = 0, tMin = double.infinity, tMax = 0;
      for (final d in entries) {
        final v = (d['voltage'] ?? 0).toDouble();
        final t = (d['temperature'] ?? 0).toDouble();
        final liters = (d['dailyLiters'] ?? 0).toDouble();
        final energy = (d['dailyEnergy'] ?? 0).toDouble();
        vSum += v;
        tSum += t;
        count += 1;
        if (liters > maxLiters) maxLiters = liters;
        if (energy > maxEnergy) maxEnergy = energy;
        if (v > vMax) vMax = v;
        if (t < tMin) tMin = t;
        if (t > tMax) tMax = t;
      }
      final vAvg = count == 0 ? 0.0 : (vSum / count);
      final tAvg = count == 0 ? 0.0 : (tSum / count);
      if (tMin == double.infinity) tMin = 0.0;
      final summary = {
        'vAvg': vAvg,
        'vMax': vMax,
        'tAvg': tAvg,
        'tMin': tMin,
        'tMax': tMax,
        'liters': maxLiters,
        'energy': maxEnergy,
      };
      final path = await _generateAndSaveDailyPdf(
        entries,
        summary: summary,
        filePrefix: 'Daily_Report',
      );
      _recordExport(path);
      await _uploadPdfToFirebase(path, summary: summary, type: 'auto');
    } catch (_) {}
  }

  Future<void> _deleteNotification(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmationModal(
            title: 'Delete Notification?',
            content:
                'Are you sure you want to delete this notification? This action cannot be undone.',
            onConfirm: () {},
          ),
    );

    if (confirmed == true) {
      if (mounted) {
        context.read<NotificationController>().deleteNotification(id);

        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => const StatusModal(
                  type: StatusType.success,
                  title: 'Deleted Successfully',
                  message: 'The notification has been removed from your list.',
                ),
          );
        }
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmationModal(
            title: 'Clear All?',
            content:
                'Are you sure you want to clear all notifications? This will delete them permanently from the cloud.',
            onConfirm: () {},
          ),
    );

    if (confirmed == true) {
      if (mounted) {
        await context.read<NotificationController>().clearAllNotifications();

        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => const StatusModal(
                  type: StatusType.success,
                  title: 'Cleared All',
                  message: 'All notifications have been removed permanently.',
                ),
          );
        }
      }
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    context.read<NotificationController>().markAsRead(notification.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getIconData(notification.iconName),
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.time,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  notification.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'warning_amber_rounded':
        return Icons.warning_amber_rounded;
      case 'thermostat_rounded':
        return Icons.thermostat_rounded;
      case 'check_circle_outline_rounded':
        return Icons.check_circle_outline_rounded;
      case 'system_update_rounded':
        return Icons.system_update_rounded;
      case 'water_drop_rounded':
        return Icons.water_drop_rounded;
      case 'bolt':
        return Icons.bolt;
      case 'cloud_off':
        return Icons.cloud_off;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomHeader(
          title: const Text('Notifications'),
          actions: [
            Consumer<NotificationController>(
              builder: (context, controller, child) {
                if (controller.notifications.isEmpty) return const SizedBox();
                return TextButton.icon(
                  onPressed: _clearAllNotifications,
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: 'Notifications'), Tab(text: 'Report')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Consumer<NotificationController>(
                    builder: (context, controller, child) {
                      if (controller.isLoading &&
                          controller.notifications.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.notifications.isEmpty) {
                        return Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => controller.loadNotifications(),
                        child: SafeArea(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                itemCount: controller.notifications.length,
                                itemBuilder: (context, index) {
                                  final notification =
                                      controller.notifications[index];

                                  final itemDelay = index * 100;
                                  final itemDuration = 600;

                                  final itemAnimation = CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      (itemDelay / 1000).clamp(0.0, 1.0),
                                      ((itemDelay + itemDuration) / 1000).clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      curve: Curves.easeOutQuart,
                                    ),
                                  );

                                  final itemFade = Tween<double>(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).animate(itemAnimation);
                                  final itemSlide = Tween<Offset>(
                                    begin: const Offset(0, 0.5),
                                    end: Offset.zero,
                                  ).animate(itemAnimation);

                                  return FadeTransition(
                                    opacity: itemFade,
                                    child: SlideTransition(
                                      position: itemSlide,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Slidable(
                                          key: ValueKey(notification.id),
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            extentRatio: 0.25,
                                            children: [
                                              CustomSlidableAction(
                                                onPressed:
                                                    (context) =>
                                                        _deleteNotification(
                                                          notification.id,
                                                        ),
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.error,
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error
                                                        .withValues(alpha: 0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          child: NotificationItem(
                                            icon: _getIconData(
                                              notification.iconName,
                                            ),
                                            title: notification.title,
                                            time: notification.time,
                                            description:
                                                notification.description,
                                            isUnread: notification.isUnread,
                                            iconBackgroundColor:
                                                AppColors.primary,
                                            onTap:
                                                () => _showNotificationDetails(
                                                  notification,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? null
                                        : Border.all(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).shadowColor.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _apiService.getSystemHistoryStream(
                                  limit: 48,
                                ),
                                builder: (context, snapshot) {
                                  final theme = Theme.of(context);
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Report',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatChip(
                                                context,
                                                'Voltage Avg',
                                                '--',
                                                theme.colorScheme.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildStatChip(
                                                context,
                                                'Water Usage',
                                                '--',
                                                theme.colorScheme.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatChip(
                                                context,
                                                'Energy Daily',
                                                '--',
                                                theme.colorScheme.tertiary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildStatChip(
                                                context,
                                                'Temp Avg',
                                                '--',
                                                theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              // Disabled during loading state
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Loading data… please wait',
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.upload_file),
                                            label: const Text('Export Report'),
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  final data = snapshot.data ?? [];
                                  final now = DateTime.now();
                                  final todays =
                                      data.where((d) {
                                        final ts = d['timestamp'];
                                        if (ts is Timestamp) {
                                          final dt = ts.toDate();
                                          return dt.year == now.year &&
                                              dt.month == now.month &&
                                              dt.day == now.day;
                                        }
                                        return false;
                                      }).toList();

                                  final live =
                                      context
                                          .read<SystemController>()
                                          .systemData;
                                  Map<String, dynamic>? liveEntry;
                                  if (live != null) {
                                    liveEntry = {
                                      'timestamp': Timestamp.fromDate(
                                        DateTime.now(),
                                      ),
                                      'voltage': live.voltage,
                                      'current': live.current,
                                      'power': live.power,
                                      'temperature': live.temperature,
                                      'dailyLiters': live.dailyLiters,
                                      'energyHour': live.energyHour,
                                      'dailyEnergy': live.dailyEnergy,
                                      'status': live.status,
                                    };
                                  }
                                  List<Map<String, dynamic>> exportEntries =
                                      List.from(todays);
                                  if (liveEntry != null) {
                                    exportEntries.add(liveEntry);
                                  }
                                  if (exportEntries.isEmpty) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Report',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'No live or historical data available to export.',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    );
                                  }
                                  double vSum = 0, tSum = 0;
                                  int count = 0;
                                  double maxLiters = 0, maxEnergy = 0;
                                  double vMax = 0,
                                      tMin = double.infinity,
                                      tMax = 0;

                                  for (final d in exportEntries) {
                                    final v = (d['voltage'] ?? 0).toDouble();
                                    final t =
                                        (d['temperature'] ?? 0).toDouble();
                                    final liters =
                                        (d['dailyLiters'] ?? 0).toDouble();
                                    final energy =
                                        (d['dailyEnergy'] ?? 0).toDouble();
                                    vSum += v;
                                    tSum += t;
                                    count += 1;
                                    if (liters > maxLiters) maxLiters = liters;
                                    if (energy > maxEnergy) maxEnergy = energy;
                                    if (v > vMax) vMax = v;
                                    if (t < tMin) tMin = t;
                                    if (t > tMax) tMax = t;
                                  }

                                  final vAvg =
                                      count == 0 ? 0.0 : (vSum / count);
                                  final tAvg =
                                      count == 0 ? 0.0 : (tSum / count);
                                  if (tMin == double.infinity) tMin = 0.0;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Report',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatChip(
                                              context,
                                              'Voltage',
                                              '${(context.watch<SystemController>().systemData?.voltage ?? 0).toStringAsFixed(1)} V',
                                              theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildStatChip(
                                              context,
                                              'Water Usage',
                                              '${(context.watch<SystemController>().systemData?.dailyLiters ?? 0).toStringAsFixed(0)} L',
                                              theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatChip(
                                              context,
                                              'Energy Daily',
                                              '${(context.watch<SystemController>().systemData?.dailyEnergy ?? 0).toStringAsFixed(1)} kWh',
                                              theme.colorScheme.tertiary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildStatChip(
                                              context,
                                              'Temperature',
                                              '${(context.watch<SystemController>().systemData?.temperature ?? 0).toStringAsFixed(1)} °C',
                                              theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () async {
                                            if (exportEntries.isEmpty) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (
                                                      context,
                                                    ) => const StatusModal(
                                                      type: StatusType.error,
                                                      title: 'No Data',
                                                      message:
                                                          'No data for today to export',
                                                    ),
                                              );
                                              return;
                                            }
                                            try {
                                              final summary = {
                                                'vAvg':
                                                    (live?.voltage ?? vAvg)
                                                        .toDouble(),
                                                'vMax': vMax.toDouble(),
                                                'tAvg':
                                                    (live?.temperature ?? tAvg)
                                                        .toDouble(),
                                                'tMin': tMin.toDouble(),
                                                'tMax': tMax.toDouble(),
                                                'liters':
                                                    (live?.dailyLiters ??
                                                            maxLiters)
                                                        .toDouble(),
                                                'energy':
                                                    (live?.dailyEnergy ??
                                                            maxEnergy)
                                                        .toDouble(),
                                              };
                                              final filePath =
                                                  await _generateAndSaveDailyPdf(
                                                    exportEntries,
                                                    summary: summary,
                                                    filePrefix: 'Manual_Report',
                                                  );
                                              _recordExport(filePath);
                                              try {
                                                await _uploadPdfToFirebase(
                                                  filePath,
                                                  summary: summary,
                                                  type: 'manual',
                                                );
                                              } catch (e) {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => StatusModal(
                                                        type: StatusType.error,
                                                        title: 'Upload Failed',
                                                        message: '$e',
                                                      ),
                                                );
                                                return;
                                              }
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => StatusModal(
                                                      type: StatusType.success,
                                                      title:
                                                          todays.isEmpty
                                                              ? 'Sample Report Exported'
                                                              : 'Report Exported',
                                                      message:
                                                          'Export completed successfully',
                                                    ),
                                              );
                                            } catch (e) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => StatusModal(
                                                      type: StatusType.error,
                                                      title:
                                                          'Failed to Generate PDF',
                                                      message: '$e',
                                                    ),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.upload_file),
                                          label: const Text('Export Report'),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const SizedBox.shrink(),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Exported Reports',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            if (_exportedPdfs.isEmpty)
                              Text(
                                'No exported PDFs yet',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              )
                            else
                              ..._exportedPdfs.map(
                                (e) => _buildExportedPdfItem(
                                  context,
                                  path: e['path'] as String,
                                  time: e['time'] as DateTime,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
