import 'package:flutter/material.dart';
import 'package:projectapp/screens/signup_screen.dart';
import 'package:projectapp/screens/landing_screen.dart';
//import 'package:projectapp/screens/home_screen.dart';
import 'package:projectapp/screens/info_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF4F3F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Bar
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LandingPage()),
                    ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Fiora",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Banner Card
              Container(
                width: double.infinity,
                height: width * 0.55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  image: const DecorationImage(
                    image: AssetImage("assets/leaves.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Colors.black.withOpacity(.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "STEP INTO CALM",
                        style: TextStyle(fontSize: 12, letterSpacing: 2),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Join the Fiora",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Full Name
              buildLabel("FULL NAME"),
              buildTextField('Joe'),

              /// Email
              buildLabel("EMAIL ADDRESS"),
              buildTextField('joe@'),

              /// Password
              buildLabel("PASSWORD"),
              buildTextField('••••••••', obscure: true),

              /// Confirm password
              buildLabel("CONFIRM PASSWORD"),
              buildTextField("••••••••", obscure: true),

              const SizedBox(height: 20),

              /// OTP Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Text(
                      "OTP VERIFICATION",
                      style: TextStyle(letterSpacing: 2),
                    ),
                    const SizedBox(height: 20),

                    /// OTP Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) => buildOtpBox()),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "We've sent a 4-digit code to your email.",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Register Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5E735F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Signed up Successfully")),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InfoPage()),
                    );
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Login text
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 12, letterSpacing: 1.5)),
  );
}

Widget buildTextField(String text, {bool obscure = false}) {
  return TextField(
    obscureText: obscure,
    decoration: InputDecoration(
      hintText: text,
      filled: true,
      fillColor: Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget buildOtpBox() {
  return SizedBox(
    width: 55,
    child: TextField(
      textAlign: TextAlign.center,
      maxLength: 1,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
