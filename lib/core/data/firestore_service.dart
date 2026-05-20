import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meal_management/core/data/default_menu.dart';

class FirestoreService {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('FirebaseFirestore unavailable: $e');
      return null;
    }
  }
  final Map<int, Map<String, dynamic>?> _menuCache = {};

  // Upload image to Cloudinary and return download URL
  Future<String?> uploadImage(XFile file) async {
    try {
      const cloudName = 'doharq576';
      const uploadPreset = 'rq3xnpqb';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final json = jsonDecode(responseString);
        return json['secure_url'] as String?;
      } else {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        debugPrint('Error uploading to Cloudinary: ${response.statusCode} - $responseString');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Add user data
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return;

      await firestore.collection('users').doc(userId).set({
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
      final firestore = _firestore;
      if (firestore == null) return null;

      DocumentSnapshot doc = await firestore.collection('users').doc(userId).get();
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
      final firestore = _firestore;
      if (firestore == null) return;

      await firestore.collection('users').doc(userId).update({
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
      final firestore = _firestore;
      if (firestore == null) return;

      final date = mealData['date'] as String;

      // Check if meal already exists for this date
        final existingMeals = await firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .where('date', isEqualTo: date)
          .get();

      if (existingMeals.docs.isNotEmpty) {
        // Update existing meal
        await existingMeals.docs.first.reference.update({
          ...mealData,
          'timestamp': FieldValue.serverTimestamp(),
        });
        debugPrint('Meal updated for user $userId on date $date');
      } else {
        // Add new meal
        await firestore
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
      final firestore = _firestore;
      if (firestore == null) return Stream.value([]);

      return firestore
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
      final firestore = _firestore;
      if (firestore == null) {
        return {
          'totalMeals': 0,
          'totalBill': 0.0,
          'remaining': 1150.0,
          'mealRate': 75.0,
        };
      }

      QuerySnapshot mealsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .where('status', isEqualTo: true)
          .get();

      // Read settings for fallback
      final settingsDoc = await firestore.collection('config').doc('meal_settings').get();
      double mealRate = 75.0;
      double monthlyLimit = 1150.0;
      if (settingsDoc.exists) {
        final data = settingsDoc.data();
        mealRate = (data?['mealRate'] ?? 75.0).toDouble();
        monthlyLimit = (data?['monthlyLimit'] ?? 1150.0).toDouble();
      }

      double totalBill = 0.0;
      int totalMealsCount = 0;

      for (var doc in mealsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final meals = data['meals'] as Map<String, dynamic>?;
        if (meals != null) {
          final rates = meals['rates'] as Map<String, dynamic>?;
          
          if (meals['breakfast'] == true) {
            totalMealsCount++;
            totalBill += (rates?['breakfast'] ?? mealRate).toDouble();
          }
          if (meals['lunch'] == true) {
            totalMealsCount++;
            totalBill += (rates?['lunch'] ?? mealRate).toDouble();
          }
          if (meals['dinner'] == true) {
            totalMealsCount++;
            totalBill += (rates?['dinner'] ?? mealRate).toDouble();
          }
        } else {
          // Fallback for old meals without details map
          totalMealsCount++;
          totalBill += mealRate;
        }
      }

      return {
        'totalMeals': totalMealsCount,
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

  // Get meal stats stream for user
  Stream<Map<String, dynamic>> getMealStatsStream(String userId) {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream.value({
        'totalMeals': 0,
        'totalBill': 0.0,
        'remaining': 1150.0,
        'mealRate': 75.0,
      });
    }

    return firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .where('status', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
          // Read settings for fallback
          final settingsDoc = await firestore.collection('config').doc('meal_settings').get();
          double mealRate = 75.0;
          double monthlyLimit = 1150.0;
          if (settingsDoc.exists) {
            final data = settingsDoc.data();
            mealRate = (data?['mealRate'] ?? 75.0).toDouble();
            monthlyLimit = (data?['monthlyLimit'] ?? 1150.0).toDouble();
          }

          double totalBill = 0.0;
          int totalMealsCount = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final meals = data['meals'] as Map<String, dynamic>?;
            if (meals != null) {
              final rates = meals['rates'] as Map<String, dynamic>?;
              
              if (meals['breakfast'] == true) {
                totalMealsCount++;
                totalBill += (rates?['breakfast'] ?? mealRate).toDouble();
              }
              if (meals['lunch'] == true) {
                totalMealsCount++;
                totalBill += (rates?['lunch'] ?? mealRate).toDouble();
              }
              if (meals['dinner'] == true) {
                totalMealsCount++;
                totalBill += (rates?['dinner'] ?? mealRate).toDouble();
              }
            } else {
              // Fallback for old meals without details map
              totalMealsCount++;
              totalBill += mealRate;
            }
          }

          return {
            'totalMeals': totalMealsCount,
            'totalBill': totalBill,
            'remaining': monthlyLimit - totalBill,
            'mealRate': mealRate,
          };
        });
  }

  // Add complaint
  Future<void> addComplaint(String userId, Map<String, dynamic> complaintData) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return;

      await firestore.collection('complaints').add({
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
      final firestore = _firestore;
      if (firestore == null) return Stream.value([]);

      return firestore
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
      final firestore = _firestore;
      if (firestore == null) return Stream.value([]);

      return firestore
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
      final firestore = _firestore;
      if (firestore == null) return Stream.value([]);

      return firestore
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
      final firestore = _firestore;
      if (firestore == null) return;

      await firestore.collection('complaints').doc(complaintId).update({
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
      final firestore = _firestore;
      if (firestore == null) return;

      await firestore.collection('users').doc(userId).update({
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
      final firestore = _firestore;
      if (firestore == null) return null;

      DocumentSnapshot doc = await firestore.collection('users').doc(userId).get();
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

  // Add a meal review
  Future<void> addReview(String userId, Map<String, dynamic> reviewData) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('reviews')
          .add({
        ...reviewData,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Review added for user $userId');
    } catch (e) {
      debugPrint('Error adding review to Firestore: $e');
      rethrow;
    }
  }

  // Get reviews stream
  Stream<List<Map<String, dynamic>>> getReviews(String userId) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    return firestore
        .collection('users')
        .doc(userId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // Get stream of all menus for the week merged with defaults
  Stream<Map<int, Map<String, dynamic>>> getWeeklyMenuStream() {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream.value(defaultWeeklyMenu);
    }
    return firestore
        .collection('menus')
        .snapshots()
        .map((snapshot) {
          final Map<int, Map<String, dynamic>> weeklyMenu = {};
          // Initialize with default menu values
          defaultWeeklyMenu.forEach((key, value) {
            weeklyMenu[key] = Map<String, dynamic>.from(value);
          });
          
          for (var doc in snapshot.docs) {
            final id = int.tryParse(doc.id);
            if (id != null) {
              weeklyMenu[id] = doc.data();
            }
          }
          return weeklyMenu;
        });
  }

  // Get menu for a specific weekday (1 = Monday, 7 = Sunday)
  Stream<Map<String, dynamic>?> getMenu(int weekday) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value(null);

    return firestore
        .collection('menus')
        .doc(weekday.toString())
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  // Get menu future for a specific weekday
  Future<Map<String, dynamic>?> getMenuFuture(int weekday) async {
    if (_menuCache.containsKey(weekday)) {
      return _menuCache[weekday];
    }
    final firestore = _firestore;
    if (firestore == null) return null;

    final doc = await firestore.collection('menus').doc(weekday.toString()).get();
    final data = doc.exists ? doc.data() : null;
    _menuCache[weekday] = data;
    return data;
  }

  // Update menu for a specific weekday
  Future<void> updateMenu(int weekday, Map<String, dynamic> menuData) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return;

      await firestore
          .collection('menus')
          .doc(weekday.toString())
          .set(menuData, SetOptions(merge: true));
      debugPrint('Menu updated for weekday $weekday');
    } catch (e) {
      debugPrint('Error updating menu in Firestore: $e');
      rethrow;
    }
  }

  // Get admin passkey from Firestore
  Future<String?> getAdminPassKey() async {
    try {
      final firestore = _firestore;
      if (firestore == null) return null;

      final doc = await firestore.collection('config').doc('admin').get();
      if (doc.exists) {
        final data = doc.data();
        return data?['passkey'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting admin passkey: $e');
      return null;
    }
  }

  // Get meal settings stream
  Stream<Map<String, dynamic>> getMealSettingsStream() {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream.value({
        'mealRate': 75.0,
        'monthlyLimit': 1150.0,
      });
    }

    return firestore
        .collection('config')
        .doc('meal_settings')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return doc.data() as Map<String, dynamic>;
          }
          return {
            'mealRate': 75.0,
            'monthlyLimit': 1150.0,
          };
        });
  }

  // Update meal settings
  Future<void> updateMealSettings(Map<String, dynamic> settings) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return;

      await firestore
          .collection('config')
          .doc('meal_settings')
          .set(settings, SetOptions(merge: true));
      debugPrint('Meal settings updated');
    } catch (e) {
      debugPrint('Error updating meal settings: $e');
      rethrow;
    }
  }
}