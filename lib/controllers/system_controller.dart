import 'dart:async';
import 'package:flutter/material.dart';
import '../models/system_data_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class SystemController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  SystemDataModel? _systemData;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<SystemDataModel?>? _subscription;

  // Track last alert time to prevent spamming
  final Map<String, DateTime> _lastAlertTime = {};
  static const _alertCooldown = Duration(minutes: 5);

  SystemDataModel? get systemData => _systemData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SystemController() {
    _initStream();
  }

  SystemDataModel _sanitize(SystemDataModel d) {
    return SystemDataModel(
      voltage: d.voltage.clamp(0.0, 260.0).toDouble(),
      current: d.current.clamp(0.0, 30.0).toDouble(),
      power: d.power.clamp(0.0, 8000.0).toDouble(),
      temperature: d.temperature.clamp(-40.0, 125.0).toDouble(),
      dailyLiters: d.dailyLiters.clamp(0.0, 10000.0).toDouble(),
      energyHour: d.energyHour.clamp(0.0, 100.0).toDouble(),
      dailyEnergy: d.dailyEnergy.clamp(0.0, 1000.0).toDouble(),
      status: d.status,
    );
  }

  void _initStream() {
    _isLoading = true;
    _subscription = _apiService.getSystemDataStream().listen(
      (data) {
        if (data != null) {
          data = _sanitize(data);
          // Check for anomalies before updating state
          _checkSystemAnomalies(data);
        }

        _systemData = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        if (e.toString().contains('permission-denied')) {
          _error = 'You do not have permission to view system data.';
        } else if (e.toString().contains('network-request-failed')) {
          _error = 'Please check your internet connection.';
        } else {
          _error = 'An error occurred while loading system data.';
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> loadSystemData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final d = await _apiService.fetchSystemData();
      _systemData = d == null ? null : _sanitize(d);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateData(
    SystemDataModel data, {
    DateTime? customTimestamp,
  }) async {
    try {
      await _apiService.updateSystemData(
        data,
        customTimestamp: customTimestamp,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _checkSystemAnomalies(SystemDataModel data) {
    // Temperature Thresholds
    if (data.temperature > 50.0) {
      _triggerSystemNotification(
        'Critical Temperature Alert',
        'System temperature has reached ${data.temperature.toStringAsFixed(1)}°C. Immediate attention required!',
      );
    } else if (data.temperature > 40.0) {
      _triggerSystemNotification(
        'High Temperature Warning',
        'System temperature is rising (${data.temperature.toStringAsFixed(1)}°C).',
      );
    }

    // Daily Liters Thresholds
    if (data.dailyLiters > 500.0) {
      _triggerSystemNotification(
        'High Water Usage',
        'System has detected high water usage (${data.dailyLiters.toStringAsFixed(1)}L today).',
      );
    }

    // Power/Voltage Thresholds
    if (data.voltage > 250.0) {
      _triggerSystemNotification(
        'Overvoltage Alert',
        'Voltage surge detected: ${data.voltage.toStringAsFixed(1)}V.',
      );
    } else if (data.voltage < 100.0 && data.voltage > 0) {
      _triggerSystemNotification(
        'Undervoltage Warning',
        'Voltage drop detected: ${data.voltage.toStringAsFixed(1)}V.',
      );
    }
    if (data.current >= 5.0) {
      _triggerSystemNotification(
        'High Current Alert',
        'Current has reached ${data.current.toStringAsFixed(1)}A.',
      );
    }
    if (data.power >= 300.0) {
      _triggerSystemNotification(
        'High Power Alert',
        'Power has reached ${data.power.toStringAsFixed(1)}W.',
      );
    }

    // Status Check
    if (data.status.toLowerCase() == 'offline') {
      _triggerSystemNotification(
        'System Offline',
        'The monitoring system has lost connection.',
      );
    }
  }

  void _triggerSystemNotification(String title, String body) async {
    // Prevent spamming the same alert too frequently
    final now = DateTime.now();
    if (_lastAlertTime.containsKey(title)) {
      if (now.difference(_lastAlertTime[title]!) < _alertCooldown) {
        return;
      }
    }
    _lastAlertTime[title] = now;

    // 1. Show local pop-up notification
    await _notificationService.showManualNotification(title: title, body: body);

    // 2. Save to Firestore notification history
    try {
      final iconName = _notificationService.getIconForTitle(title);
      final iconColorHex = _notificationService.getColorForTitle(title);

      await _apiService.addNotification(
        title: title,
        description: body,
        iconName: iconName,
        iconColorHex: iconColorHex,
      );
    } catch (e) {
      debugPrint('Failed to auto-save anomaly notification: $e');
    }

    debugPrint('SYSTEM ALERT TRIGGERED: $title - $body');
  }
}
