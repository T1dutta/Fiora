// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../theme/app_colors.dart';

// class TrackerScreen extends StatelessWidget {
//   const TrackerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.surface,
//       child: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//         children: [
//           Text(
//             'Ethreal',
//             style: GoogleFonts.manrope(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.05 * 12,
//               color: AppColors.onSurfaceVariant,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Today • Day 12',
//             style: GoogleFonts.manrope(
//               fontSize: 16,
//               color: AppColors.onSurface,
//             ),
//           ),
//           const SizedBox(height: 8),

//           // Display LG
//           Text(
//             'Follicular Phase',
//             style: GoogleFonts.manrope(
//               fontSize: 56,
//               fontWeight: FontWeight.w700,
//               color: AppColors.onSurface,
//             ),
//           ),

//           const SizedBox(height: 48),

//           Text(
//             'September 2024',
//             style: GoogleFonts.manrope(
//               fontSize: 28, // headline-md
//               fontWeight: FontWeight.w600,
//               color: AppColors.onSurface,
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Cycle Prediction Card: Recessed
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: AppColors.surfaceContainerLow,
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Cycle Prediction',
//                   style: GoogleFonts.manrope(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Next period predicted in 18 days',
//                   style: GoogleFonts.manrope(
//                     fontSize: 16,
//                     color: AppColors.onSurfaceVariant,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 48),

//           Text(
//             'Upcoming Cycles',
//             style: GoogleFonts.manrope(
//               fontSize: 28,
//               fontWeight: FontWeight.w600,
//               color: AppColors.onSurface,
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Cycle List
//           _buildCycleRow('September 30', 'Likely'),
//           const SizedBox(height: 12),
//           _buildCycleRow('October 28', 'Predicted'),
//           const SizedBox(height: 12),
//           _buildCycleRow('November 25', 'Predicted'),

//           const SizedBox(height: 48),

//           Text(
//             'Daily Log',
//             style: GoogleFonts.manrope(
//               fontSize: 28,
//               fontWeight: FontWeight.w600,
//               color: AppColors.onSurface,
//             ),
//           ),
//           const SizedBox(height: 120),
//         ],
//       ),
//     );
//   }

//   Widget _buildCycleRow(String date, String status) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceContainerHigh,
//         borderRadius: BorderRadius.circular(32),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             date,
//             style: GoogleFonts.manrope(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: AppColors.onSurface,
//             ),
//           ),
//           Text(
//             status,
//             style: GoogleFonts.manrope(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: AppColors.secondary, // Terracotta accent
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});
  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  int selectedMood = 1;
  int selectedFlow = 2;
  Set<int> selectedSymptoms = {};
  double painLevel = 3;
  final List<String> flowOptions = ["None", "Light", "Medium", "Heavy"];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _trackerHeader(),

            const SizedBox(height: 20),

            Text(
              "TODAY • DAY 12",
              style: GoogleFonts.manrope(
                fontSize: 12,
                letterSpacing: 1.2,
                color: AppColors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Follicular Phase",
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            _phaseTabs(),

            const SizedBox(height: 20),

            _calendarCard(),

            const SizedBox(height: 20),

            _predictionCard(),

            const SizedBox(height: 20),

            _upcomingCard(),

            const SizedBox(height: 20),

            _dailyLogCard(),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  /// HEADER
  Widget _trackerHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 20, child: Icon(Icons.spa)),
        const SizedBox(width: 12),
        Text(
          "Fiora",
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1E4632),
          ),
        ),
        const Spacer(),
        // const Icon(Icons.notifications_none),
      ],
    );
  }

  /// PHASE TABS
  // Widget _phaseTabs() {
  //   return Container(
  //     padding: const EdgeInsets.all(6),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade200,
  //       borderRadius: BorderRadius.circular(30),
  //     ),
  //     child: Row(
  //       children: [
  //         _tab("Menstrual", true),
  //         _tab("Follicular", false),
  //         _tab("Ovulatory", false),
  //         _tab("Luteal", false),
  //       ],
  //     ),
  //   );
  // }

  Widget _phaseTabs() {
    final phases = ["Menstrual", "Follicular", "Ovulatory", "Luteal"];
    int selectedIndex = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: List.generate(
              phases.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? const Color(0xFFB65A3A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        phases[index],
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _tab(String text, bool active) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 8),
  //       decoration: BoxDecoration(
  //         color: active ? const Color(0xFFB65A3A) : Colors.transparent,
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       child: Center(
  //         child: Text(
  //           text,
  //           style: GoogleFonts.manrope(
  //             fontSize: 12,
  //             color: active ? Colors.white : Colors.grey,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _legendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.manrope(fontSize: 11)),
      ],
    );
  }

  Widget _calendarCard() {
    final days = List.generate(30, (index) => index + 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF1ECE6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// MONTH HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.chevron_left),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// WEEK DAYS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                .map(
                  (e) => Expanded(
                    child: Center(
                      child: Text(
                        e,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 12),

          /// DAYS GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final day = days[index];

              return AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: day == 11
                          ? const Color(0xffDDE6DE)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$day",
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: day == 12
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          /// LEGEND
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _legendDot(Color(0xFFB65A3A), "Menstruation"),
              _legendDot(Color(0xFFD4A373), "Ovulation"),
              _legendDot(Colors.grey, "PMS Window"),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _legend(Color color, String text) {
  //   return Row(
  //     children: [
  //       CircleAvatar(radius: 4, backgroundColor: color),
  //       const SizedBox(width: 6),
  //       Text(text, style: GoogleFonts.manrope(fontSize: 11)),
  //     ],
  //   );
  // }

  /// PREDICTION CARD
  Widget _predictionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff4A6353),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cycle Prediction",
            style: GoogleFonts.manrope(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "Next period\npredicted in 18\ndays",
            style: GoogleFonts.manrope(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// UPCOMING CARD
  Widget _upcomingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upcoming Cycles",
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _cycle("September 30", "Likely"),
          _cycle("October 28", "Predicted"),
          _cycle("November 25", "Predicted"),
        ],
      ),
    );
  }

  Widget _cycle(String date, String tag) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(date),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(tag, style: GoogleFonts.manrope(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  /// DAILY LOG
  Widget _dailyLogCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF1ECE6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Log",
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 25),

          Text("FLOW INTENSITY", style: GoogleFonts.manrope(fontSize: 10)),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(flowOptions.length, (index) {
              final isSelected = selectedFlow == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFlow = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white70,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFB65A3A)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    flowOptions[index],
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 35),

          _moodSection(),
          const SizedBox(height: 17),

          _symptomsSection(),

          const SizedBox(height: 40),

          Text("PAIN LEVEL", style: GoogleFonts.manrope(fontSize: 10)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: painLevel,
              min: 0,
              max: 10,
              divisions: 10,
              label: painLevel.round().toString(),
              onChanged: (value) {
                setState(() {
                  painLevel = value;
                });
              },
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4A6353),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                print('Saved log');
              },

              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  "Save Daily Log",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodSection() {
    final moods = [
      {"icon": Icons.sentiment_satisfied_alt, "label": "Happy"},
      {"icon": Icons.sentiment_satisfied, "label": "Calm"},
      {"icon": Icons.sentiment_neutral, "label": "Neutral"},
      {"icon": Icons.sentiment_dissatisfied, "label": "Irritable"},
      {"icon": Icons.sentiment_very_dissatisfied, "label": "Low"},
    ];

    //int selected = 2; // Calm selected

    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Text(
    //       "MOOD",
    //       style: GoogleFonts.manrope(
    //         fontSize: 11,
    //         letterSpacing: 1.2,
    //         color: Colors.black,
    //       ),
    //     ),
    //     const SizedBox(height: 12),

    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: List.generate(moods.length, (index) {
    //         final isSelected = selectedMood == index;

    //         return Expanded(
    //           child: Column(
    //             children: [
    //               Container(
    //                 padding: const EdgeInsets.all(10),
    //                 decoration: BoxDecoration(
    //                   color: isSelected
    //                       ? const Color(0xff4E6355)
    //                       : Colors.white,
    //                   shape: BoxShape.circle,
    //                 ),
    //                 child: Icon(
    //                   moods[index]["icon"] as IconData,
    //                   size: 18,
    //                   color: isSelected ? Colors.white : Colors.black54,
    //                 ),
    //               ),
    //               const SizedBox(height: 6),
    //               Text(
    //                 moods[index]["label"] as String,
    //                 style: GoogleFonts.manrope(fontSize: 10),
    //               ),
    //             ],
    //           ),
    //         );
    //       }),
    //     ),
    //   ],
    // );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "MOOD",
          style: GoogleFonts.manrope(
            fontSize: 11,
            letterSpacing: 1.2,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          // <-- changed from Row (responsive)
          alignment: WrapAlignment.spaceEvenly,
          runSpacing: 12,
          children: List.generate(moods.length, (index) {
            final isSelected = selectedMood == index;

            return GestureDetector(
              // <-- makes it clickable
              onTap: () {
                setState(() {
                  selectedMood = index;
                });
              },
              child: SizedBox(
                width:
                    MediaQuery.of(context).size.width / 5.7, // responsive width
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xff4E6355)
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        moods[index]["icon"] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      moods[index]["label"] as String,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Widget _symptomsSection() {
  //   final symptoms = ["Bloating", "Cramps", "Headache", "Backache", "Acne"];

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(height: 24),

  //       Text(
  //         "SYMPTOMS",
  //         style: GoogleFonts.manrope(
  //           fontSize: 11,
  //           letterSpacing: 1.2,
  //           color: Colors.grey,
  //         ),
  //       ),

  //       const SizedBox(height: 12),

  //       Wrap(
  //         spacing: 8,
  //         runSpacing: 8,
  //         children: List.generate(symptoms.length, (index) {
  //           final isSelected = selectedSymptoms.contains(index);// cramps selected

  //           return Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  //             decoration: BoxDecoration(
  //               color: selected ? Colors.white : Colors.white,
  //               borderRadius: BorderRadius.circular(20),
  //               border: Border.all(
  //                 color: selected
  //                     ? const Color(0xff4E6355)
  //                     : Colors.grey.shade300,
  //               ),
  //             ),
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 if (selected)
  //                   const Icon(
  //                     Icons.check_circle,
  //                     size: 14,
  //                     color: Color(0xff4E6355),
  //                   ),

  //                 if (selected) const SizedBox(width: 6),

  //                 Text(
  //                   symptoms[index],
  //                   style: GoogleFonts.manrope(fontSize: 12),
  //                 ),
  //               ],
  //             ),
  //           );
  //         }),
  //       ),
  //     ],
  //   );
  // }

  Widget _symptomsSection() {
    final symptoms = ["Bloating", "Cramps", "Headache", "Backache", "Acne"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        Text(
          "SYMPTOMS",
          style: GoogleFonts.manrope(
            fontSize: 11,
            letterSpacing: 1.2,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(symptoms.length, (index) {
            final isSelected = selectedSymptoms.contains(index);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedSymptoms.remove(index);
                  } else {
                    selectedSymptoms.add(index);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xff4E6355)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Color(0xff4E6355),
                      ),

                    if (isSelected) const SizedBox(width: 6),

                    Text(
                      symptoms[index],
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Widget _chip(String text, {bool active = false}) {
  //   return Container(
  //     margin: const EdgeInsets.only(right: 8),
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: active ? Colors.white : Colors.white70,
  //       borderRadius: BorderRadius.circular(20),
  //       border: active ? Border.all(color: const Color(0xFFB65A3A)) : null,
  //     ),
  //     child: Text(text),
  //   );
  // }

}

