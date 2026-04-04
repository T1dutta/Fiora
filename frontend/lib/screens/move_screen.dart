// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import '../theme/app_colors.dart';

// // class MoveScreen extends StatelessWidget {
// //   const MoveScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       color: AppColors.surface,
// //       child: ListView(
// //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
// //         children: [
// //           // Display LG
// //           Text(
// //             'Move with your flow.',
// //             style: GoogleFonts.manrope(
// //               fontSize: 56,
// //               fontWeight: FontWeight.w700,
// //               color: AppColors.onSurface,
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           Text(
// //             "Inhale... Exhale...",
// //             style: GoogleFonts.manrope(
// //               fontSize: 16,
// //               color: AppColors.onSurfaceVariant,
// //             ),
// //           ),

// //           const SizedBox(height: 48),

// //           // Metabolic HIIT Title
// //           Text(
// //             'Metabolic HIIT Surge',
// //             style: GoogleFonts.manrope(
// //               fontSize: 28,
// //               fontWeight: FontWeight.w600,
// //               color: AppColors.onSurface,
// //             ),
// //           ),
// //           const SizedBox(height: 24),

// //           // Workout Achievement Card: primary-to-lighter-sage gradient
// //           Container(
// //             padding: const EdgeInsets.all(32),
// //             decoration: BoxDecoration(
// //               gradient: const LinearGradient(
// //                 colors: [AppColors.primary, AppColors.primaryContainer],
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //               ),
// //               borderRadius: BorderRadius.circular(40),
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     const Icon(
// //                       Icons.check_circle_outline,
// //                       color: Colors.white,
// //                       size: 28,
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Text(
// //                       'Workout saved!',
// //                       style: GoogleFonts.manrope(
// //                         fontSize: 22,
// //                         fontWeight: FontWeight.w700,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   'Building a beautiful streak. Energy metrics updated. You have successfully aligned your movement with your natural rhythm.',
// //                   style: GoogleFonts.manrope(
// //                     fontSize: 16,
// //                     height: 1.5,
// //                     color: Colors.white.withOpacity(0.95),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(height: 60),

// //           // Specialized Visual: The Breath Module Circular Pulsing Placeholder
// //           Center(
// //             child: Container(
// //               width: 240,
// //               height: 240,
// //               decoration: BoxDecoration(
// //                 color: AppColors.surfaceContainerLowest,
// //                 shape: BoxShape.circle,
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: AppColors.primary.withOpacity(0.08),
// //                     blurRadius: 60,
// //                     spreadRadius: 20,
// //                   ),
// //                 ],
// //               ),
// //               child: Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     const Icon(
// //                       Icons.circle,
// //                       color: AppColors.primary,
// //                       size: 12,
// //                     ),
// //                     const SizedBox(height: 12),
// //                     Text(
// //                       'FOCUS',
// //                       style: GoogleFonts.manrope(
// //                         fontSize: 12,
// //                         letterSpacing: 4,
// //                         fontWeight: FontWeight.w800,
// //                         color: AppColors.primary,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 120),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';

// class MoveScreen extends StatefulWidget {
//   const MoveScreen({super.key});

//   @override
//   State<MoveScreen> createState() => _MoveScreenState();
// }

// class _MoveScreenState extends State<MoveScreen> {
//   bool isPlaying = false;
//   double progress = 0.6;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF7F3EE),
//       floatingActionButton: _fab(),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _header(),

//               const SizedBox(height: 20),

//               _title(),

//               const SizedBox(height: 16),

//               _phaseChip(),

//               const SizedBox(height: 20),

//               _breathingCard(),

//               const SizedBox(height: 20),

//               _workoutCard(),

//               const SizedBox(height: 20),

//               _audioCard(),

//               const SizedBox(height: 20),

//               _savedCard(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // HEADER
//   Widget _header() {
//     return Row(
//       children: [
//         const CircleAvatar(radius: 18),
//         const SizedBox(width: 10),

//         const Text(
//           "The Sanctuary",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),

//         const Spacer(),

//         IconButton(
//           onPressed: () {},
//           icon: const Icon(Icons.notifications_none),
//         ),
//       ],
//     );
//   }

//   // TITLE
//   Widget _title() {
//     return const Text(
//       "Move with your\nflow.",
//       style: TextStyle(fontSize: 34, fontWeight: FontWeight.w600, height: 1.2),
//     );
//   }

//   // PHASE CHIP
//   Widget _phaseChip() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(color: Colors.orange.shade200),
//       ),
//       child: const Text(
//         "FOLLICULAR PHASE: HIGH ENERGY",
//         style: TextStyle(fontSize: 11, letterSpacing: 1.2),
//       ),
//     );
//   }

//   // BREATHING CARD
//   Widget _breathingCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       height: 220,
//       decoration: BoxDecoration(
//         color: const Color(0xff8B5E3C),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "CURRENT SESSION",
//             style: TextStyle(
//               fontSize: 10,
//               letterSpacing: 2,
//               color: Colors.white70,
//             ),
//           ),

//           const SizedBox(height: 10),

//           const Text(
//             "12:45",
//             style: TextStyle(
//               fontSize: 42,
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             ),
//           ),

//           const SizedBox(height: 6),

//           const Text(
//             "Inhale... Exhale...",
//             style: TextStyle(color: Colors.white70),
//           ),

//           const Spacer(),

//           Row(
//             children: [
//               _pauseButton(),

//               const SizedBox(width: 16),

//               _stopButton(),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _pauseButton() {
//     return CircleAvatar(
//       radius: 24,
//       backgroundColor: Colors.white24,
//       child: IconButton(
//         icon: const Icon(Icons.pause, color: Colors.white),
//         onPressed: () {},
//       ),
//     );
//   }

//   Widget _stopButton() {
//     return CircleAvatar(
//       radius: 26,
//       backgroundColor: Colors.green,
//       child: IconButton(
//         icon: const Icon(Icons.stop, color: Colors.white),
//         onPressed: () {},
//       ),
//     );
//   }

//   // WORKOUT CARD
//   Widget _workoutCard() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         color: Colors.white,
//       ),
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//             child: Image.asset(
//               "assets/workout.png",
//               height: 220,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "FOLLICULAR PHASE",
//                   style: TextStyle(
//                     fontSize: 10,
//                     letterSpacing: 1.5,
//                     color: Colors.orange,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 const Text(
//                   "Metabolic HIIT Surge",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                 ),

//                 const SizedBox(height: 10),

//                 Row(
//                   children: const [
//                     Icon(Icons.schedule, size: 16),
//                     SizedBox(width: 6),
//                     Text("25m"),

//                     SizedBox(width: 20),

//                     Icon(Icons.local_fire_department, size: 16),
//                     SizedBox(width: 6),
//                     Text("High"),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // AUDIO CARD
//   Widget _audioCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xff6D3F25),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const CircleAvatar(radius: 24),

//               const SizedBox(width: 12),

//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Deep Focus Ambiance",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),

//                     Text(
//                       "Spatial Audio Enabled",
//                       style: TextStyle(color: Colors.white70, fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.skip_previous, color: Colors.white),
//               ),

//               CircleAvatar(
//                 radius: 26,
//                 backgroundColor: Colors.white24,
//                 child: IconButton(
//                   icon: Icon(
//                     isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       isPlaying = !isPlaying;
//                     });
//                   },
//                 ),
//               ),

//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.skip_next, color: Colors.white),
//               ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           LinearProgressIndicator(
//             value: progress,
//             backgroundColor: Colors.white24,
//             color: Colors.green,
//           ),
//         ],
//       ),
//     );
//   }

//   // SAVED CARD
//   Widget _savedCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xffF1ECE6),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.check_circle, color: Colors.green),
//               SizedBox(width: 8),
//               Text(
//                 "Workout saved!",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),

//           const SizedBox(height: 6),

//           const Text("Building a beautiful streak.\nEnergy metrics updated."),

//           const SizedBox(height: 16),

//           Row(
//             children: [
//               _stat("DURATION", "20m"),

//               const SizedBox(width: 12),

//               _stat("ENERGY", "185 kcal"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _stat(String title, String value) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           children: [
//             Text(title, style: const TextStyle(fontSize: 10)),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // FAB
//   Widget _fab() {
//     return FloatingActionButton(
//       backgroundColor: Colors.green,
//       onPressed: () {},
//       child: const Icon(Icons.add),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
//import 'package:intl/intl.dart';

class MoveScreen extends StatefulWidget {
  const MoveScreen({super.key});

  @override
  State<MoveScreen> createState() => _MoveScreenState();
}

class _MoveScreenState extends State<MoveScreen>
    with SingleTickerProviderStateMixin {
  /// breathing animation
  late AnimationController _breathController;

  /// countdown timer
  int seconds = 600; // 12:45
  Timer? timer;

  /// workout state
  bool isPaused = false;
  bool workoutStarted = false;

  /// audio player
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int playingIndex = -1;

  final player1 = AudioPlayer();
  final player2 = AudioPlayer();

  /// streak counter
  int streak = 5;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    player.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });

    player.onPositionChanged.listen((p) {
      setState(() => position = p);
    });

    player.onPlayerComplete.listen((event) {
      setState(() => isPlaying = false);
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      }
    });
  }

  String get time {
    final m = (seconds ~/ 60).toString().padLeft(2, "0");
    final s = (seconds % 60).toString().padLeft(2, "0");
    return "$m:$s";
  }

  @override
  void dispose() {
    timer?.cancel();
    _breathController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF7F3EE),
      child: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  _title(),
                  const SizedBox(height: 20),
                  _streak(),
                  const SizedBox(height: 26),
                  _breathingCard(),
                  const SizedBox(height: 50),
                  _workoutCard(),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Expanded(child: _audioCard1("Action", Icons.graphic_eq)),
                      const SizedBox(width: 12),
                      Expanded(child: _audioCard2("Calmness", Icons.water)),
                    ],
                  ),
                ],
              ),
            ),
            // FAB positioned at bottom-right
            Positioned(
              bottom: 16,
              right: 16,
              child: _fab(),
            ),
          ],
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
        Text("Fiora"),
        Spacer(),
        // Icon(Icons.notifications_none),
      ],
    );
  }

  /// TITLE
  Widget _title() {
    return const Text(
      "Move with your\nflow.",
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    );
  }

  /// STREAK
  Widget _streak() {
    return Row(
      children: [
        const Icon(Icons.local_fire_department, color: Colors.orange),
        const SizedBox(width: 6),
        Text("$streak day streak"),
      ],
    );
  }

  Widget _breathingCard() {
    return Container(
      height: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff8B5E3C),
        borderRadius: BorderRadius.circular(30),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = MediaQuery.of(context).size.width;
          final h = MediaQuery.of(context).size.height;
          //constraints.maxWidthconstraints.maxHeight
          return Stack(
            children: [
              /// RIGHT BIG CIRCLE
              Positioned(
                right: -w * .15,
                top: h * .05,
                child: Container(
                  width: w * .75,
                  height: w * .75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.08),
                  ),
                ),
              ),

              /// LEFT SOFT CIRCLE
              Positioned(
                left: -w * .25,
                bottom: -h * .15,
                child: Container(
                  width: w * .65,
                  height: w * .65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.06),
                  ),
                ),
              ),

              /// CONTENT
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CURRENT SESSION",
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Text(
                    "Inhale... Exhale...",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      /// pause
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white24,
                        child: IconButton(
                          icon: Icon(
                            isPaused ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (isPaused) {
                              startTimer();
                            } else {
                              timer?.cancel();
                            }

                            setState(() {
                              isPaused = !isPaused;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// stop
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: const Icon(
                            Icons.stop,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            timer?.cancel();
                            setState(() {
                              seconds = 600;
                              isPaused = false;
                            });

                            startTimer();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// WORKOUT CARD
  Widget _workoutCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Image.asset(
              "assets/workout.png",
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("FOLLICULAR PHASE"),

                const SizedBox(height: 8),

                const Text(
                  "Metabolic HIIT Surge",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                Row(
                  children: const [
                    Icon(Icons.schedule, size: 16),
                    SizedBox(width: 6),
                    Text("25m"),
                    SizedBox(width: 16),
                    Icon(Icons.local_fire_department, size: 16),
                    SizedBox(width: 6),
                    Text("High"),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        workoutStarted = !workoutStarted;
                        streak++;
                      });
                    },
                    child: Text(
                      workoutStarted ? "Workout Started" : "Start Workout",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AUDIO CARD
  Widget _audioCard2(String title, IconData icon) {
    final isPlaying = playingIndex == 1;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff6D3F25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.withOpacity(.3),
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text(title, style: TextStyle(color: Colors.white)),
            ],
          ),

          const SizedBox(height: 20),

          Center(
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white24,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await player1.stop(); // stop other

                  if (isPlaying) {
                    await player2.pause();
                    playingIndex = -1;
                  } else {
                    await player2.play(AssetSource("yoga.mp3"));
                    playingIndex = 1;
                  }

                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: (duration.inMilliseconds == 0)
                ? 0
                : position.inMilliseconds / duration.inMilliseconds,

            backgroundColor: Colors.white24,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _audioCard1(String title, IconData icon) {
    final isPlaying = playingIndex == 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff6D3F25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.withOpacity(.3),
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text(title, style: TextStyle(color: Colors.white)),
            ],
          ),

          const SizedBox(height: 20),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     // IconButton(
          //     //   icon: const Icon(Icons.skip_previous, color: Colors.white),
          //     //   onPressed: () {},
          //     // ),
          //     Expanded(
          //       child: CircleAvatar(
          //         //play button
          //         radius: 26,
          //         backgroundColor: Colors.white24,
          //         child: IconButton(
          //           icon: Icon(
          //             isPlaying ? Icons.pause : Icons.play_arrow,
          //             color: Colors.white,
          //           ),
          //           onPressed: () async {
          //             if (isPlaying) {
          //               await player.pause();
          //             } else {
          //               await player.play(AssetSource("fitness.mp3"));
          //             }

          //             setState(() {
          //               isPlaying = !isPlaying;
          //             });
          //           },
          //         ),
          //       ),
          //     ),

          //     // IconButton(
          //     //   icon: const Icon(Icons.skip_next, color: Colors.white),
          //     //   onPressed: () {},
          //     // ),
          //   ],
          // ),
          Center(
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white24,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await player2.stop(); // stop other

                  if (isPlaying) {
                    await player1.pause();
                    playingIndex = -1;
                  } else {
                    await player1.play(AssetSource("fitness.mp3"));
                    playingIndex = 0;
                  }

                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: (duration.inMilliseconds == 0)
                ? 0
                : position.inMilliseconds / duration.inMilliseconds,

            backgroundColor: Colors.white24,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _fab() {
    return FloatingActionButton(
      backgroundColor: Colors.green,
      onPressed: () {
        setState(() {
          streak++;
        });
      },
      child: const Icon(Icons.add),
    );
  }
}
