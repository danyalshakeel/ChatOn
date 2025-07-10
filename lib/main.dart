import 'package:chaton/Screen/Home/home_page.dart';
import 'package:chaton/Screen/Search/searchUser_screen.dart';
import 'package:chaton/Screen/Splash/splash_screen.dart';
import 'package:chaton/Screen/auth/sign_in.dart';
import 'package:chaton/Screen/auth/sign_up.dart';
import 'package:chaton/Services/auth_services.dart';
import 'package:chaton/Services/user_services.dart';
import 'package:chaton/appLifecycle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    final authServices = AuthServices();
    print("AuthServices: $authServices");
    final databaseServices = DatabaseServices();
    print("DatabaseServices: $databaseServices");
    authServices.setDatabaseServices(databaseServices);
    runApp(MainApp());
  } catch (e, s) {
    print(
      "3333333333333333333333333333333333333333333333333333333333333333333333",
    );
    print('Firebase Init Error: $e');
    print('Stack trace: $s');
  }
}

class MainApp extends StatelessWidget with WidgetsBindingObserver {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: SignInScreen(),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        // '/': (context) => AuthServices().currentUser != null
        //     ? AppLifecycleHandler(child: HomePage())
        //     : SignInScreen(),

        //  '/': (context) => AuthServices().currentUser != null
        //     ? HomePage()
        //     : SignInScreen(),
        '/applifecycle': (context) => AppLifecycleHandler(child: HomePage()),
        '/home': (context) => HomePage(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/searchUser': (context) => SearchUserScreen(),
      },
    );
  }
}
