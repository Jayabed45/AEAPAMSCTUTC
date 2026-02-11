import 'dart:async';
import 'package:flutter/material.dart';
import '../models/system_data_model.dart';
import '../services/api_service.dart';
import '../utils/mock_data_util.dart';

class SystemController with ChangeNotifier {
  final ApiService _apiService = ApiService();

  SystemDataModel? _systemData;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<SystemDataModel>? _subscription;

  SystemDataModel? get systemData => _systemData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SystemController() {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    _subscription = _apiService.getSystemDataStream().listen(
      (data) {
        // Check for anomalies before updating state
        _checkSystemAnomalies(data);

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
      _systemData = await _apiService.fetchSystemData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> simulateDataUpdate({int? hour}) async {
    try {
      await MockDataUtil.insertMockSystemData(hour: hour);
    } catch (e) {
      _error = e.toString();
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

  Future<void> generateFullDayData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await MockDataUtil.simulateFullDay();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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

    // Water Level Thresholds
    if (data.waterLevel < 10) {
      _triggerSystemNotification(
        'Critical Water Level',
        'Water level is extremely low (${data.waterLevel}%). System shutdown imminent.',
      );
    } else if (data.waterLevel < 25) {
      _triggerSystemNotification(
        'Low Water Level',
        'Water level is below 25%. Please refill soon.',
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

    // Status Check
    if (data.status.toLowerCase() == 'offline') {
      _triggerSystemNotification(
        'System Offline',
        'The monitoring system has lost connection.',
      );
    }
  }

  void _triggerSystemNotification(String title, String body) {
    // In a real app, this would be triggered by a Cloud Function
    // monitoring Firestore. Here we simulate the local saving of
    // the notification which would happen if an FCM message arrived.
    // We don't want to spam notifications every second if data is streaming,
    // so in a real scenario, logic to prevent duplicate alerts would be needed.

    // For demonstration, we'll log it.
    debugPrint('SYSTEM ALERT: $title - $body');
  }
}
