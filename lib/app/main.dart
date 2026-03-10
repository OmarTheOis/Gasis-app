import 'package:flutter/material.dart';

import '../features/auth/Screens/splash_screen.dart';
import '../utils/navigation.dart';
import '../utils/themes.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: Navigations.routes,
      home: SplashScreen(),

    );
  }
}

