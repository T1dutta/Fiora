import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/fiora_api.dart';
import '../services/user_prefs.dart';
import '../theme/app_colors.dart';
import 'alerts_screen.dart';
import 'main_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greetFirstName = 'there';

  // FIX: AI insight state — was a single hardcoded string.
  // Now we track loading/error/real-data states from GET /health_analysis/analyze.
  bool _insightLoading = true;
  String? _insightTitle;
  String? _insightBody;
  String? _insightError;

  @override
  void initState() {
    super.initState();
    _loadGreetingFromCacheThenApi();
    _loadAiInsight();
  }

  Future<void> _loadGreetingFromCacheThenApi() async {
    final cached = await UserPrefs.readProfileName();
    if (cached != null && cached.isNotEmpty && mounted) {
      setState(() => _greetFirstName = _firstNameFromFullName(cached));
    }
    try {
      final me = await FioraApi().fetchProfileMe();
      final profile = me['profile'];
      if (profile is Map && profile['name'] != null) {
        final raw = profile['name'].toString().trim();
        if (raw.isNotEmpty) {
          await UserPrefs.saveProfileName(raw);
          if (mounted) {
            setState(() => _greetFirstName = _firstNameFromFullName(raw));
          }
        }
      }
    } catch (_) {
      // No token or network: keep cache or "there".
    }
  }

  /// FIX: call POST /api/v1/health_analysis/analyze to get a live insight.
  /// Previously this was a static string embedded in the widget.
  Future<void> _loadAiInsight() async {
    setState(() {
      _insightLoading = true;
      _insightError = null;
    });
    try {
      final result = await FioraApi().analyzeHealth(windowDays: 7);
      if (!mounted) return;
      // The backend returns a free-form JSON from the ML service.
      // We surface `title` + `summary` if present, or fall back gracefully.
      setState(() {
        _insightTitle = result['title']?.toString() ?? 'Your Health Insight';
        _insightBody = result['summary']?.toString() ??
            result['message']?.toString() ??
            'No new insight available yet. Log a few more days to get personalised analysis.';
        _insightLoading = false;
      });
    } on FioraApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Not logged in — silently hide the card.
        setState(() {
          _insightLoading = false;
          _insightError = null; // hide card entirely for unauthed users
        });
      } else {
        setState(() {
          _insightLoading = false;
          _insightError = 'Could not load insight (${e.statusCode}).';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _insightLoading = false;
        _insightError = 'Could not connect to the server.';
      });
    }
  }

  static String _firstNameFromFullName(String full) {
    final parts =
        full.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? 'there' : parts.first;
  }

  static String _timeBasedGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "THE JOURNAL",
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        letterSpacing: 1.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "fiora",
                      style: GoogleFonts.manrope(
                        fontSize: 29,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Health alerts',
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const AlertsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_outlined),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _heroCard(),
            const SizedBox(height: 24),

            // FIX: replaces the old hardcoded _aiInsight() widget.
            _aiInsightLive(),

            const SizedBox(height: 24),

            Text(
              "Quick Actions",
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                InkWell(
                  onTap: () => TabSwitcher.of(context).switchTo(1),
                  child: _quickCard(Icons.edit, "Log Today", "Record your feelings"),
                ),
                InkWell(
                  onTap: () => TabSwitcher.of(context).switchTo(2),
                  child: _quickCard(Icons.chat, "Chat with AI", "24/7 Guidance"),
                ),
                InkWell(
                  onTap: () => TabSwitcher.of(context).switchTo(4),
                  child: _quickCard(Icons.fitness_center, "Exercise", "Move your body"),
                ),
                InkWell(
                  onTap: () => TabSwitcher.of(context).switchTo(3),
                  child: _quickCard(Icons.menu_book, "Learn", "Expert articles"),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _streakCard(),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Badge Collection",
                  style: GoogleFonts.manrope(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text(
                  "VIEW ALL",
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _badge("FIRST QUIZ MASTER"),
                const SizedBox(width: 16),
                _badge("7-DAY TRACKER"),
              ],
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 420,
        child: Stack(
          children: [
            Image.asset(
              "assets/goodmorning.png",
              height: 420,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withOpacity(.5), Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "VOLUME 12 • FOLLICULAR PHASE",
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // FIX: greeting uses live _greetFirstName from GET /profiles/me
                  // rather than a name baked into the hero image.
                  Text(
                    "${_timeBasedGreeting()},\n$_greetFirstName.",
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\"You're in your power phase today.\"",
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(child: _glass("STATUS", "Calm\nMood")),
                      const SizedBox(width: 12),
                      Expanded(child: _glass("NEXT UP", "Morning\nMeditation")),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glass(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIX: _aiInsightLive replaces the old hardcoded _aiInsight() widget.
  //
  // Old code:
  //   Text("\"Your cortisol levels typically peak in 2 hours. A 5-minute ...")
  //
  // New behaviour:
  //  • Shows a shimmer placeholder while loading.
  //  • Renders real data from POST /api/v1/health_analysis/analyze.
  //  • Shows a retry button on network error.
  //  • Hides the card entirely for unauthenticated users (401).
  // ─────────────────────────────────────────────────────────────────────────
  Widget _aiInsightLive() {
    // Don't show the card at all if there was a 401.
    if (!_insightLoading && _insightError == null && _insightTitle == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff254f44),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb_outline, size: 16),
                SizedBox(width: 4),
                Text("AI INSIGHT", style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_insightLoading) ...[
            // Shimmer-style placeholder
            Container(
              height: 22,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 14,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ] else if (_insightError != null) ...[
            Text(
              _insightError!,
              style: GoogleFonts.manrope(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadAiInsight,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
              ),
              child: const Text("RETRY",
                  style: TextStyle(color: Colors.white)),
            ),
          ] else ...[
            Text(
              _insightTitle ?? '',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${_insightBody ?? ''}"',
              style: GoogleFonts.manrope(color: Colors.white70, height: 1.6),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadAiInsight,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
              ),
              child: const Text("REFRESH",
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing smartwatch...')));
                  await FioraApi().syncMockSmartwatch();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Smartwatch synced!')));
                  await _loadAiInsight();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sync failed: $e')));
                }
              },
              icon: const Icon(Icons.watch, color: Colors.white, size: 18),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
              ),
              label: const Text("Sync Smartwatch (Simulated)",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _quickCard(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, size: 18),
          ),
          const Spacer(),
          Text(title,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
          Text(sub,
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _streakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffEDE3DA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 0.25,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFFB65A3A)),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("14",
                        style: GoogleFonts.manrope(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    Text("DAYS",
                        style: GoogleFonts.manrope(
                            fontSize: 8, letterSpacing: 1.2)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("14-Day Streak!",
                  style:
                      GoogleFonts.manrope(fontWeight: FontWeight.w600)),
              Text(
                "You're more consistent than 85% of users.",
                style: GoogleFonts.manrope(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String title) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 32,
          backgroundColor: Color.fromARGB(255, 6, 77, 7),
          child: Icon(Icons.star_outline_sharp),
        ),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.manrope(fontSize: 11)),
      ],
    );
  }
}
