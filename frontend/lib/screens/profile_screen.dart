import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SanctuaryProfileScreen extends StatefulWidget {
  const SanctuaryProfileScreen({super.key});

  @override
  State<SanctuaryProfileScreen> createState() => _SanctuaryProfileScreenState();
}

class _SanctuaryProfileScreenState extends State<SanctuaryProfileScreen> {
  /// toggles
  bool dataSovereignty = true;
  bool emailReflections = true;
  bool pushNotifications = true;
  bool voiceGuidance = false;
  bool notifyPartner = false;
  final TextEditingController partnerController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF6F3EE),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),

              const SizedBox(height: 20),

              _profileSection(),

              const SizedBox(height: 30),

              _insightSection(),

              const SizedBox(height: 30),

              _flowBarChart(),

              const SizedBox(height: 30),

              _dataSanctuary(),

              const SizedBox(height: 30),

              _channelsSection(),

              const SizedBox(height: 30),

              _partnerNotificationCard(),

              const SizedBox(height: 30),

              _specialists(),

              const SizedBox(height: 30),

              _reflectionCard(),

              const SizedBox(height: 30),
              _logoutButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// HEADER
  Widget _header() {
    return Row(
      children: const [
        CircleAvatar(radius: 18, child: Icon(Icons.spa)),
        SizedBox(width: 10),
        Text("FIORA"),
        Spacer(),
        ImageIcon(AssetImage('assets/meditation.png'), size: 30),
      ],
    );
  }

  /// PROFILE
  Widget _profileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "A JOURNEY WITHIN",
          style: TextStyle(letterSpacing: 2, fontSize: 11, color: Colors.brown),
        ),

        const SizedBox(height: 10),

        const Text(
          "Elena\nRichardson",
          style: TextStyle(
            fontSize: 32,
            height: 1.1,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "“Cultivating peace through the gentle\nobservation of my own nature.”",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("EDIT PROFILE"),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("SHARE"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// INSIGHT TEXT
  Widget _insightSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Harmonizing Your Inner Rhythm", style: TextStyle(fontSize: 18)),

        SizedBox(height: 8),

        Text(
          "Reflecting on the ebb and flow of the past six months.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  /// DATA SANCTUARY
  Widget _dataSanctuary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Sacred Data ", style: TextStyle(fontSize: 18)),

        const SizedBox(height: 10),

        _toggleTile(
          "Data Sovereignty",
          "Authenticated via secure protocol",
          dataSovereignty,
          (v) => setState(() => dataSovereignty = v),
        ),
      ],
    );
  }

  /// CHANNELS
  Widget _channelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Channels of Stillness", style: TextStyle(fontSize: 18)),

        const SizedBox(height: 12),

        _toggleTile(
          "Email Reflections",
          "",
          emailReflections,
          (v) => setState(() => emailReflections = v),
        ),

        _toggleTile(
          "Push Notifications",
          "",
          pushNotifications,
          (v) => setState(() => pushNotifications = v),
        ),

        _toggleTile(
          "Voice Guidance",
          "",
          voiceGuidance,
          (v) => setState(() => voiceGuidance = v),
        ),
      ],
    );
  }

  Widget _partnerNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF1ECE6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Send notification to partner?",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              Switch(
                value: notifyPartner,
                onChanged: (v) {
                  setState(() => notifyPartner = v);
                },
              ),
            ],
          ),

          /// show when toggle ON
          if (notifyPartner) ...[
            const SizedBox(height: 12),

            TextField(
              controller: partnerController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter partner phone number",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // request permission
                  print("Grant permission clicked");
                },
                child: const Text("Grant Permission"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// TOGGLE TILE (Reusable)
  Widget _toggleTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),

          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  /// SPECIALISTS
  Widget _specialists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Connect with specialists", style: TextStyle(fontSize: 20)),

        const SizedBox(height: 16),

        _doctorCard("Dr. Aris Thorne"),
        const SizedBox(height: 16),
        _doctorCard("Dr. Julian Vane"),
      ],
    );
  }

  Widget _doctorCard(String name) {
    return Column(
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 28),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name),
                  const SizedBox(height: 4),
                  const Text(
                    "ENDOCRINOLOGY",
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("DEEP DIVE BIO"),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("BEGIN DIALOGUE"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _flowBarChart() {
    final months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    final flowData = [
      1.0,
      2.0,
      3.0,
      2.0,
      1.0,
      2.0,
      2.0,
      3.0,
      1.0,
      2.0,
      1.0,
      2.0,
    ];

    return Container(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF1ECE6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Flow",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width, // scrollable width
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          String text = "";

                          switch (value.toInt()) {
                            case 0:
                              text = "None";
                              break;
                            case 1:
                              text = "Light";
                              break;
                            case 2:
                              text = "Med";
                              break;
                            case 3:
                              text = "Heavy";
                              break;
                          }

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  barGroups: List.generate(
                    12,
                    (index) => _bar(index, flowData[index]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 10,
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFFB65A3A),
        ),
      ],
    );
  }

  /// REFLECTION CARD
  Widget _reflectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff6E645C),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Icon(Icons.self_improvement, color: Colors.white),

          SizedBox(height: 12),

          Text(
            "Moment of Reflection",
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),

          SizedBox(height: 12),

          Text(
            "There is no limit to what we, as women, can accomplish",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: const BorderSide(color: Colors.red),
        ),
        onPressed: () {
          _showLogoutDialog();
        },
        child: const Text(
          "LOG OUT",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Log out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              /// TODO: logout logic
              print("User Logged Out");

              /// example navigation
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (_) => LoginScreen()),
              // );
            },
            child: const Text("Log out"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    partnerController.dispose();
    super.dispose();
  }
}
