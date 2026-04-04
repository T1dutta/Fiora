import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'tracker_screen.dart';
import 'ai_screen.dart';
import 'learn_screen.dart';
import 'move_screen.dart';
import 'profile_screen.dart';

/// InheritedWidget that lets any descendant screen switch tabs
/// without needing a direct reference to MainScaffold's state.
///
/// Usage from any child screen:
///   TabSwitcher.of(context).switchTo(1); // switches to Tracker tab
class TabSwitcher extends InheritedWidget {
  final void Function(int index) switchTo;
  final int currentIndex;

  const TabSwitcher({
    super.key,
    required this.switchTo,
    required this.currentIndex,
    required super.child,
  });

  static TabSwitcher of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabSwitcher>()!;
  }

  /// Safe version that returns null if not inside a MainScaffold.
  static TabSwitcher? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabSwitcher>();
  }

  @override
  bool updateShouldNotify(TabSwitcher oldWidget) {
    return currentIndex != oldWidget.currentIndex;
  }
}

/// The single Scaffold that wraps the entire main app experience.
///
/// - [TopAppBar] and [BottomNavBar] are declared ONCE here and never rebuild
///   when the user switches tabs.
/// - [IndexedStack] keeps every child alive so widget state (scroll position,
///   text fields, timers, etc.) is preserved across tab switches.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // All tab screens — these must NOT contain their own Scaffold.
  final List<Widget> _screens = const [
    HomeScreen(),      // 0
    TrackerScreen(),   // 1
    AiScreen(),        // 2
    LearnScreen(),     // 3
    MoveScreen(),      // 4
    SanctuaryProfileScreen(), // 5
  ];

  /// Per-tab floating action buttons (null = no FAB for that tab).
  List<Widget?> get _fabs => [
        null, // Home
        FloatingActionButton(
          backgroundColor: const Color(0xFFB65A3A),
          onPressed: () => debugPrint("Tracker: Add clicked"),
          child: const Icon(Icons.add),
        ), // Tracker
        null, // AI
        null, // Learn
        null, // Move — FAB is embedded inside MoveScreen itself
        null, // Profile
      ];

  @override
  Widget build(BuildContext context) {
    return TabSwitcher(
      switchTo: _switchTab,
      currentIndex: _currentIndex,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFFFBF9F6),
        appBar: const TopAppBar(),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        floatingActionButton: _fabs[_currentIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _switchTab,
        ),
      ),
    );
  }
}
