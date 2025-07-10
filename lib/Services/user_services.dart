import 'package:chaton/Model/user_model.dart';
import 'package:chaton/Services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'user';
  final String? _userId = AuthServices().currentUserId;

  // void setAuthServices(AuthServices authServices) {
  //   authServices.setDatabaseServices(this);
  // }

  /// Adds a new user document to Firestore
  Future<void> addUser(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection(_collection).doc(uid).set(userData);
      print('User added successfully');
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  /// Retrieves a user document by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      print('User retrieved successfully: ${doc.id}');
      print('User data: ${doc.data()}');

      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Updates an existing user document with provided fields
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(uid).update(updates);
      print('User updated successfully');
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Deletes a user document by UID
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
      print('User deleted successfully');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  /// Retrieves a list of all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      print('Retrieved ${snapshot.docs.length} users');
      print('User data: ${snapshot.docs.map((doc) => doc.data()).toList()}');
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<List<String>> allUserNames() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      final data = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      final userNames = data.map((user) => user.userName).toList();
      return userNames;
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    if (_userId == null) {
      print("UserId is null there");
      return;
    }
    await _firestore.collection(_collection).doc(_userId).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

  Stream<bool> getOnlineStatus(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['isOnline']);
  }
}
