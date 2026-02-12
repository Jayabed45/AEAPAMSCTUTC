import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationController with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<NotificationModel>>? _subscription;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NotificationController() {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    _subscription = _apiService.getNotificationsStream().listen(
      (data) {
        _notifications = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        if (e.toString().contains('permission-denied')) {
          _error = 'You do not have permission to view notifications.';
        } else if (e.toString().contains('network-request-failed')) {
          _error = 'Please check your internet connection.';
        } else {
          _error = 'An error occurred while loading notifications.';
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

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _apiService.fetchNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiService.markNotificationAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = _notifications[index];
        _notifications[index] = NotificationModel(
          id: old.id,
          title: old.title,
          description: old.description,
          time: old.time,
          isUnread: false,
          iconName: old.iconName,
          iconColorHex: old.iconColorHex,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _apiService.deleteNotification(id);
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearAllNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.clearAllNotifications();
      _notifications.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
