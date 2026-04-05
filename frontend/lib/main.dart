import 'package:flutter/material.dart';
import 'package:projectapp/screens/landing_screen.dart';
import 'package:projectapp/screens/login_screen.dart';
import 'package:projectapp/screens/signup_screen.dart';
import 'package:projectapp/screens/info_screen.dart';
import 'package:projectapp/screens/main_scaffold.dart';
import 'package:projectapp/screens/alerts_screen.dart';
import 'theme/app_theme.dart';

import 'package:magic_sdk/magic_sdk.dart';

void main() {
  Magic.instance = Magic("pk_live_C238F6B2B9E51067");
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

      // Initialize Magic Relayer to sit on top of all navigated routes natively
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            Magic.instance.relayer,
          ],
        );
      },

      // Auth flow starts here — no persistent bars on these screens
      initialRoute: "/register",

      routes: {
        "/register": (context) => const LandingPage(),
        "/login": (context) => const LoginPage(),
        "/signup": (context) => const SignupScreen(),
        "/info": (context) => const InfoPage(),

        // Main app — persistent AppBar + BottomNav via MainScaffold
        "/home": (context) => const MainScaffold(),
        "/alerts": (context) => const AlertsScreen(),
      },
    );
  }
}
