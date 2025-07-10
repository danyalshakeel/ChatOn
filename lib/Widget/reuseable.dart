import 'package:flutter/material.dart';

Widget horizontalGap(double gap) {
  return SizedBox(width: gap);
}

Widget verticalGap(double gap) {
  return SizedBox(height: gap);
}

Color greenColor = Colors.teal;
Color lightGreenColor = Colors.teal.withOpacity(0.5);

Widget CustomeButton({
  required String text,
  required VoidCallback onPressed,
  Color? color,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.black,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
    ),
  );
}

/// Centralized application color definitions

/// Background
const Color lightBgColor = Color(0xFFE9F8D7);
const Color greyBgColor = Color(0xFFF5F5F5);
// imary Greens

const Color darkGreenColor = Color(0xFF388E3C);
//xt
const Color darkTextColor = Color(0xFF212121);
const Color greyTextColor = Color(0xFF757575);



String reuseCapitalize(String s) =>
    s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;



noInternet(BuildContext context) {
  return AlertDialog(
    title: Text('No Internet'),
    content: Text('Please check your internet connection.'),
    actions: <Widget>[
      TextButton(
        child: Text('OK'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}