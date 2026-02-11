import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../models/system_data_model.dart';
import '../models/user_model.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- System Data ---
  Stream<SystemDataModel> getSystemDataStream() {
    return _firestore.collection('system').doc('current_data').snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return SystemDataModel.fromJson(doc.data()!);
      } else {
        throw Exception('System data document not found');
      }
    });
  }

  Future<SystemDataModel> fetchSystemData() async {
    try {
      // Assuming a single document for system status
      final doc =
          await _firestore.collection('system').doc('current_data').get();

      if (doc.exists) {
        return SystemDataModel.fromJson(doc.data()!);
      } else {
        throw Exception('System data document not found');
      }
    } catch (e) {
      throw Exception('Failed to load system data from Firebase: $e');
    }
  }

  // --- Notifications ---
  Stream<List<NotificationModel>> getNotificationsStream() {
    return _firestore
        .collection('notifications')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return NotificationModel.fromJson(data);
          }).toList();
        });
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('notifications')
              .orderBy('time', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Use Firestore document ID
        return NotificationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load notifications from Firebase: $e');
    }
  }

  // --- User Profile ---
  Future<UserModel> fetchUserProfile() async {
    try {
      // Assuming user profile is stored in 'users' collection with a specific ID
      // In a real app, you'd use the current user's UID from Firebase Auth
      final doc =
          await _firestore.collection('users').doc('default_user').get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      } else {
        throw Exception('User profile not found');
      }
    } catch (e) {
      throw Exception('Failed to load profile from Firebase: $e');
    }
  }

  // Helper method to mark notification as read in Firebase
  Future<void> markNotificationAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({
      'is_unread': false,
    });
  }

  // Helper method to delete notification from Firebase
  Future<void> deleteNotification(String id) async {
    await _firestore.collection('notifications').doc(id).delete();
  }
}
