import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add user data
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('User $userId added to Firestore');
    } catch (e) {
      debugPrint('Error adding user to Firestore: $e');
      rethrow;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user from Firestore: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('User $userId updated in Firestore');
    } catch (e) {
      debugPrint('Error updating user in Firestore: $e');
      rethrow;
    }
  }

  // Add or update a meal document
  Future<void> addMeal(String userId, Map<String, dynamic> mealData) async {
    try {
      final date = mealData['date'] as String;
      final status = mealData['status'] as bool;

      // Check if meal already exists for this date
      final existingMeals = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .where('date', isEqualTo: date)
          .get();

      if (existingMeals.docs.isNotEmpty) {
        // Update existing meal
        await existingMeals.docs.first.reference.update({
          'status': status,
          'timestamp': FieldValue.serverTimestamp(),
        });
        debugPrint('Meal updated for user $userId on date $date');
      } else {
        // Add new meal
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('meals')
            .add({
              ...mealData,
              'timestamp': FieldValue.serverTimestamp(),
            });
        debugPrint('Meal added for user $userId on date $date');
      }
    } catch (e) {
      debugPrint('Error adding/updating meal to Firestore: $e');
      rethrow;
    }
  }

  // Get meals for a user
  Stream<List<Map<String, dynamic>>> getMeals(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList();
          });
    } catch (e) {
      debugPrint('Error getting meals stream: $e');
      return Stream.value([]);
    }
  }

  // Get meal stats for user
  Future<Map<String, dynamic>> getMealStats(String userId) async {
    try {
      QuerySnapshot mealsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .where('status', isEqualTo: true)
          .get();

      int totalMeals = mealsSnapshot.docs.length;
      double mealRate = 75.0; // Could be configurable
      double totalBill = totalMeals * mealRate;
      double monthlyLimit = 1150.0; // Could be configurable

      return {
        'totalMeals': totalMeals,
        'totalBill': totalBill,
        'remaining': monthlyLimit - totalBill,
        'mealRate': mealRate,
      };
    } catch (e) {
      debugPrint('Error getting meal stats: $e');
      return {
        'totalMeals': 0,
        'totalBill': 0.0,
        'remaining': 1150.0,
        'mealRate': 75.0,
      };
    }
  }

  // Add complaint
  Future<void> addComplaint(String userId, Map<String, dynamic> complaintData) async {
    try {
      await _firestore.collection('complaints').add({
        'userId': userId,
        ...complaintData,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Complaint added for user $userId');
    } catch (e) {
      debugPrint('Error adding complaint: $e');
      rethrow;
    }
  }

  // Get complaints for user
  Stream<List<Map<String, dynamic>>> getComplaints(String userId) {
    try {
      return _firestore
          .collection('complaints')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList();
          });
    } catch (e) {
      debugPrint('Error getting complaints stream: $e');
      return Stream.value([]);
    }
  }

  // Admin: Get all users
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    try {
      return _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList();
          });
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return Stream.value([]);
    }
  }

  // Admin: Get all complaints
  Stream<List<Map<String, dynamic>>> getAllComplaints() {
    try {
      return _firestore
          .collection('complaints')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList();
          });
    } catch (e) {
      debugPrint('Error getting all complaints: $e');
      return Stream.value([]);
    }
  }

  // Admin: Update complaint status
  Future<void> updateComplaintStatus(String complaintId, String status) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Complaint $complaintId status updated to $status');
    } catch (e) {
      debugPrint('Error updating complaint status: $e');
      rethrow;
    }
  }

  // Save user preferences (including date range)
  Future<void> saveUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('User preferences saved for $userId');
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
      rethrow;
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['preferences'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return null;
    }
  }
}