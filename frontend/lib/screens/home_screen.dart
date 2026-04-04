import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'main_scaffold.dart'; // for TabSwitcher

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

                // Row(
                //   children: [
                //     const Icon(Icons.notifications_none),
                //     const SizedBox(width: 12),
                //     CircleAvatar(
                //       radius: 18,
                //       backgroundColor: AppColors.primary,
                //       child: const Icon(Icons.person, size: 18),
                //     ),
                //   ],
                // ),
              ],
            ),

            const SizedBox(height: 24),

            /// HERO CARD
            _heroCard(),

            const SizedBox(height: 24),

            /// AI INSIGHT
            _aiInsight(),

            const SizedBox(height: 24),

            /// QUICK ACTIONS
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
                  child: _quickCard(
                    Icons.edit,
                    "Log Today",
                    "Record your feelings",
                  ),
                ),
                InkWell(
                  onTap: () => TabSwitcher.of(context).switchTo(2),
                  child: _quickCard(
                    Icons.chat,
                    "Chat with AI",
                    "24/7 Guidance",
                  ),
                ),
                InkWell(
                  onTap: () => TabSwitcher.of(context).switchTo(4),
                  child: _quickCard(
                    Icons.fitness_center,
                    "Exercise",
                    "Move your body",
                  ),
                ),
                InkWell(
                  onTap: () => TabSwitcher.of(context).switchTo(3),
                  child: _quickCard(
                    Icons.menu_book,
                    "Learn",
                    "Expert articles",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// STREAK
            _streakCard(),

            const SizedBox(height: 24),

            /// BADGE HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Badge Collection",
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
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

  /// HERO
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

                  Text(
                    "Good morning,\nMaya.",
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

  /// GLASS CARD
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
          Text(
            title,
            style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11),
          ),
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

  /// AI INSIGHT
  Widget _aiInsight() {
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
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline),
                Text("AI INSIGHT", style: TextStyle(fontSize: 11)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Optimal Energy Window",
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "\"Your cortisol levels typically peak in 2 hours. "
            "A 5-minute breathing exercise now will stabilize "
            "your energy for the afternoon meeting.\"",
            style: GoogleFonts.manrope(color: Colors.white70, height: 1.6),
          ),

          const SizedBox(height: 16),

          OutlinedButton(
            onPressed: () {
              print('Music');
            },
            child: const Text(
              "LISTEN TO AUDIO",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// QUICK CARD
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
          Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
          Text(
            sub,
            style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// STREAK
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
                    valueColor: AlwaysStoppedAnimation(Color(0xFFB65A3A)),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "14",
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "DAYS",
                      style: GoogleFonts.manrope(
                        fontSize: 8,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "14-Day Streak!",
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
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

  /// BADGE
  Widget _badge(String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: const Color.fromARGB(255, 6, 77, 7),
          child: const Icon(Icons.star_outline_sharp),
        ),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.manrope(fontSize: 11)),
      ],
    );
  }
}
