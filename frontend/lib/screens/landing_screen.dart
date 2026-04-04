import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB86A8A), // pink purple
              Color(0xFFE6A57E), // peach
              Color(0xFFE9D9A8), // soft yellow
              Color(0xFFAED6C5), // mint
              Color(0xFF8FB3D9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: Colors.white.withOpacity(.75),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// Logo + Title
                  Row(
                    children: const [
                      Icon(Icons.spa, color: Color(0xff4F6B52)),
                      SizedBox(width: 10),
                      Text(
                        "FIORA",
                        style: TextStyle(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff4F6B52),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * .18),

                  /// Title
                  const Text(
                    "Welcome to your\nFiora",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// Subtitle
                  const Text(
                    "A digital space for your body's\nnatural rhythms",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Dot indicator
                  // Container(
                  //   width: 6,
                  //   height: 6,
                  //   decoration: const BoxDecoration(
                  //     color: Colors.grey,
                  //     shape: BoxShape.circle,
                  //   ),
                  // ),
                  const Spacer(),

                  /// Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        /// navigate to register page
                        Navigator.pushNamed(context, "/login");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4F6B52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Begin Your Journey",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
