import 'dart:async';
import 'package:flutter/material.dart';
import '../models/system_data_model.dart';
import '../services/api_service.dart';

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
}
