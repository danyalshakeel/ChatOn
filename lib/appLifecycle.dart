import 'package:chaton/Services/auth_services.dart';
import 'package:chaton/Services/user_services.dart';
import 'package:flutter/material.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  final String? userId = AuthServices().currentUserId ?? "";
  final DatabaseServices _databaseServices = DatabaseServices();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (userId!.isNotEmpty) _databaseServices.setOnlineStatus(true);
   
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (userId!.isEmpty) return;

    if (state == AppLifecycleState.resumed) {
      _databaseServices.setOnlineStatus(true);
    } else if (
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _databaseServices.setOnlineStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
