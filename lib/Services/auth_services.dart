import 'package:chaton/Model/user_model.dart';
import 'package:chaton/Services/chat_services.dart';
import 'package:chaton/Services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void setDatabaseServices(DatabaseServices db) {}

  User? get currentUser => _auth.currentUser;

  /// Signs in an existing user with email & password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DatabaseServices().setOnlineStatus(true);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('SignIn Error [${e.code}]: ${e.message}');
      rethrow;
    }
  }

  /// Signs up a new user and persists profile data to Firestore
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String userName,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'USER_NULL',
          message: 'User registration failed',
        );
      }

      // Update display name on FirebaseAuth profile
      await user.updateDisplayName(displayName);

      print(" Display Name: $displayName");

      // Build UserModel
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: displayName,
        userName: userName,
        createdAt: DateTime.now(),
      );

      print(
        "UserModel: ${newUser.uid}, ${newUser.email}, ${newUser.displayName}, ${newUser.userName}, ${newUser.createdAt}",
      );

      Map<String, dynamic> userJson = newUser.toJson();

      print("userJson: $userJson");

      // Save to Firestore via DatabaseServices
      await DatabaseServices().addUser(user.uid, userJson);
      print('User signed up and saved to Firestore: ${user.uid}');
      return user;
    } on FirebaseAuthException catch (e) {
      print('SignUp Error [${e.code}]: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected SignUp Error: $e');
      rethrow;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      DatabaseServices().setOnlineStatus(false);
      await _auth.signOut();

      print('User signed out: ${_auth.currentUser?.uid}');
      _auth.currentUser != null;
      print('User signed out successfully');
    } catch (e) {
      print('SignOut Error: $e');
      rethrow;
    }
  }

  /// Returns the UID of the currently signed-in user, or null if none.
  String? get currentUserId => _auth.currentUser?.uid;
}
