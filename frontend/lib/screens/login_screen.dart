import 'package:flutter/material.dart';
import 'package:projectapp/screens/signup_screen.dart';
import 'package:projectapp/screens/landing_screen.dart';
import '../services/fiora_api.dart';
import '../services/auth_token_store.dart';
import '../services/user_prefs.dart';

/// LoginPage — this screen is the REGISTER entry point reached from LandingPage.
/// It now delegates ALL real account creation to SignupScreen (which calls
/// FioraApi().signup() and stores the JWT).  The old "Sign Up" button used to
/// navigate directly to InfoPage without touching the backend; that is fixed.
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
                      MaterialPageRoute(builder: (context) => const LandingPage()),
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
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "STEP INTO CALM",
                        style: TextStyle(fontSize: 12, letterSpacing: 2),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Join Fiora",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Create your account to start tracking your cycle, get AI insights and personalised recommendations.",
                style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              /// FIX: "Sign Up" now opens SignupScreen (real API call + JWT storage).
              /// Previously this button pushed directly to InfoPage, bypassing the
              /// backend entirely and discarding all entered data.
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// FIX: "Already have an account? Login" now opens the real login
              /// flow (LoginFormScreen below) instead of SignupScreen.
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginFormScreen(),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────


class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final api = FioraApi();
      // POST /api/v1/auth/login — returns { access_token }
      await api.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      // Eagerly fetch the user's name so the home greeting is correct
      // immediately after login.
      try {
        final me = await api.fetchProfileMe();
        final name = (me['profile'] as Map?)?['name']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          await UserPrefs.saveProfileName(name);
        }
      } catch (_) {
        // Non-fatal; home screen will retry.
      }
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FioraApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.body}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F3F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    const Text('Fiora',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('WELCOME BACK',
                    style: TextStyle(letterSpacing: 1.5, fontSize: 12)),
                const SizedBox(height: 8),
                const Text(
                  'Log in to your account',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
                ),
                const SizedBox(height: 32),
                _field('Email', _email, (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter email';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                }),
                _field('Password', _password, (v) {
                  if (v == null || v.length < 6) return 'Enter password';
                  return null;
                }, obscure: true),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4F6B52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Login',
                            style:
                                TextStyle(fontSize: 17, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c,
    String? Function(String?) validator, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 6),
          TextFormField(
            controller: c,
            obscureText: obscure && _obscure,
            keyboardType: obscure
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
            decoration: InputDecoration(
              suffixIcon: obscure
                  ? IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
