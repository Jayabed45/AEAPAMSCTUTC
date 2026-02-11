import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  List<Map<String, dynamic>> get historyData => _historyData;
  bool get isLoading => _isLoading;

  StatisticsController() {
    _initStream();
  }

  Future<void> reloadData() async {
    _isLoading = true;
    notifyListeners();
    _subscription?.cancel();
    _initStream();
    // Wait for the first data point to arrive or a timeout
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _initStream() {
    _subscription = _apiService.getSystemHistoryStream().listen((data) {
      _historyData = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<FlSpot> getVoltageSpots() {
    return _historyData.map((d) => FlSpot(d['hour'], (d['voltage'] as num).toDouble())).toList();
  }

  List<FlSpot> getCurrentSpots() {
    return _historyData.map((d) => FlSpot(d['hour'], (d['current'] as num).toDouble())).toList();
  }

  List<FlSpot> getPowerSpots() {
    return _historyData.map((d) => FlSpot(d['hour'], (d['power'] as num).toDouble())).toList();
  }

  List<FlSpot> getTemperatureSpots() {
    return _historyData.map((d) => FlSpot(d['hour'], (d['temperature'] as num).toDouble())).toList();
  }

  List<FlSpot> getEnergySpots() {
    return _historyData.map((d) => FlSpot(d['hour'], (d['energy_hour'] as num).toDouble())).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
