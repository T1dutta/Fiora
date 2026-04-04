import 'package:flutter/material.dart';
import 'package:projectapp/screens/landing_screen.dart';
import 'package:projectapp/screens/login_screen.dart';
import 'package:projectapp/screens/signup_screen.dart';
import 'package:projectapp/screens/info_screen.dart';
import 'package:projectapp/screens/main_scaffold.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiora Wellness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Auth flow starts here — no persistent bars on these screens
      initialRoute: "/register",

      routes: {
        "/register": (context) => const LandingPage(),
        "/login": (context) => const LoginPage(),
        "/signup": (context) => const SignupScreen(),
        "/info": (context) => const InfoPage(),

        // Main app — persistent AppBar + BottomNav via MainScaffold
        "/home": (context) => const MainScaffold(),
      },
    );
  }
}
