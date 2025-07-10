import 'package:chaton/Widget/reuseable.dart';
import 'package:chaton/helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashServices {
  static final SplashServices _instance = SplashServices._internal();
  factory SplashServices() => _instance;
  SplashServices._internal();

  // Initialize app and check authentication
  Future<void> initializeApp(BuildContext context) async {
    try {
      // Add minimum splash duration for better UX
      await Future.delayed(const Duration(seconds: 3));

      print("Splash Screen Services");

      // Check internet connectivity

      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        noInternet(context);

        // throw Exception('No internet connection');
      }

      // Initialize Firebase and other services
      await _initializeServices();

      // Check authentication status
      final user = FirebaseAuth.instance.currentUser;
      print(user);
      // Navigate based on auth status
      if (user != null) {
        print(user.uid + " User is navigating to home screen");
        await _navigateToHome(context);
      } else {
        print("${user} User is navigating to home screen");
        await _navigateToAuth(context);
      }
    } catch (e) {
      // Handle errors
      _handleInitializationError(e, context);
    }
  }

  // Initialize all required services
  Future<void> _initializeServices() async {
    // Initialize Firebase
    // await Firebase.initializeApp();
    if(FirebaseAuth.instance.currentUser != null)
    onSplashFetchChats(FirebaseAuth.instance.currentUser!.uid);
    // Initialize local storage
    // await SharedPreferences.getInstance();

    // Initialize notification services
    // await NotificationService().initialize();

    // Load user preferences
    // await UserPreferences().loadPreferences();

    // Any other initialization
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Navigate to home screen
  Future<void> _navigateToHome(context) async {
    print("Navigating to home screen");
    try {
      Navigator.pushNamed(context, '/applifecycle');
      await navigatorKey.currentState?.pushReplacementNamed('/applifecycle');
      print("Navigated to home screen");
    } catch (e) {
      print("Error during navigation $e");
    }
  }

  // Navigate to authentication screen
  Future<void> _navigateToAuth(context) async {
    print("Navigating to auth screen");
      Navigator.pushNamed(context, '/signin');
    await navigatorKey.currentState?.pushReplacementNamed('/signin');
  }

  // Handle initialization errors
  void _handleInitializationError(dynamic error, BuildContext context) {
    // Show error dialog or navigate to error screen
    showDialog(
      context: navigatorKey.currentContext??context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text('Connection Error'),
          ],
        ),
        content: Text(
          'Unable to connect to the server. Please check your internet connection and try again.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retry initialization
              initializeApp(context);
            },
            child: Text('Retry', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  // Check for app updates
  Future<bool> checkForUpdates() async {
    // Implement update check logic
    // Return true if update is available
    return false;
  }

  // Load user data if authenticated
  Future<void> loadUserData(String userId) async {
    try {
      // Load user profile
      // await UserRepository().getUserProfile(userId);

      // Load user preferences
      // await UserPreferences().loadUserSpecificPreferences(userId);

      // Initialize chat services
      // await ChatServices().initialize(userId);

      // Load cached messages
      // await MessageCache().loadCachedMessages(userId);
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Clear cache and temporary data
  Future<void> clearTemporaryData() async {
    // Clear image cache
    // imageCache.clear();

    // Clear temporary files
    // await TempFileManager().clearTempFiles();
  }
}

// Global navigator key for navigation from services
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Extension for easier navigation
// extension NavigationExtension on BuildContext {
//   Future<void> navigateToHome() async {
//     print("Navigating to home screen");
//     await Navigator.of(this).pushReplacementNamed('/applifecycle');
//     print("Navigated to home screen");
//   }

//   Future<void> navigateToAuth() async {
//     await Navigator.of(this).pushReplacementNamed('/signin');
//   }
// }
