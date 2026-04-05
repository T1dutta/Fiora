import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_sdk/magic_sdk.dart';

import '../services/fiora_api.dart';
import '../services/user_prefs.dart';

/// Full signup: collects profile + health fields and POSTs `/api/v1/auth/signup`.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _age = TextEditingController();
  final _email = TextEditingController();
  final _cycleLength = TextEditingController();
  final _avgPeriod = TextEditingController();
  final _emergency = TextEditingController();

  bool _submitting = false;

  /// Step: toggled condition labels sent as `known_conditions` (lowercase tags).
  final Set<String> _conditionTags = {};

  static const _chipOptions = [
    'PCOS',
    'Endometriosis',
    'Adenomyosis',
    'Fibroids',
    'None noted',
  ];

  final _api = FioraApi();

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _email.dispose();
    _cycleLength.dispose();
    _avgPeriod.dispose();
    _emergency.dispose();
    super.dispose();
  }

  List<String> _conditionsPayload() {
    if (_conditionTags.contains('None noted')) {
      return [];
    }
    return _conditionTags
        .where((e) => e != 'None noted')
        .map((e) => e.toLowerCase())
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final email = _email.text.trim();
      final trimmedName = _name.text.trim();

      // Step 1: Magic sends an email OTP to the user. The Magic overlay
      // (injected via main.dart relayer) handles the UI. When the user
      // clicks/confirms, getIdToken() returns a signed DID token.
      await Magic.instance.auth.loginWithEmailOTP(email: email);
      final didToken = await Magic.instance.user.getIdToken();
      if (didToken == null || didToken.isEmpty) {
        throw Exception('Magic did not return a DID token');
      }

      // Step 2: POST DID token + health profile to our backend.
      // The backend validates the token with MAGIC_SECRET_KEY, creates the
      // user + profile in MongoDB, and returns a Fiora JWT.
      await _api.magicSignup(
        didToken: didToken,
        name: trimmedName,
        age: int.parse(_age.text.trim()),
        cycleLength: _cycleLength.text.trim().isEmpty
            ? null
            : int.tryParse(_cycleLength.text.trim()),
        avgPeriodLength: int.parse(_avgPeriod.text.trim()),
        knownConditions: _conditionsPayload(),
        emergencyContact: _emergency.text.trim(),
      );

      await UserPrefs.saveProfileName(trimmedName);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FioraApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.body}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F4F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    const Text(
                      'Fiora',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(letterSpacing: 1.5, fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your health profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                _field('Full name', _name, (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter your name';
                  }
                  return null;
                }),
                _field('Age', _age, (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Required';
                  }
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 13 || n > 120) {
                    return 'Valid age 13–120';
                  }
                  return null;
                }, number: true),
                _field('Email', _email, (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter email';
                  }
                  if (!v.contains('@')) {
                    return 'Invalid email';
                  }
                  return null;
                }),
                _field(
                  'Typical cycle length (days, optional)',
                  _cycleLength,
                  (v) {
                    if (v == null || v.trim().isEmpty) {
                      return null;
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 21 || n > 45) {
                      return 'Use 21–45 or leave blank';
                    }
                    return null;
                  },
                  number: true,
                  optional: true,
                ),
                _field(
                  'Average period length (days)',
                  _avgPeriod,
                  (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Required';
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 1 || n > 14) {
                      return 'Use 1–14 days';
                    }
                    return null;
                  },
                  number: true,
                ),
                _field(
                  'Emergency contact phone',
                  _emergency,
                  (v) {
                    if (v == null || v.trim().length < 7) {
                      return 'Enter a reachable number';
                    }
                    return null;
                  },
                  hint: '+1 555 000 0000',
                ),
                const SizedBox(height: 8),
                const Text(
                  'KNOWN CONDITIONS',
                  style: TextStyle(fontSize: 11, letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _chipOptions.map((label) {
                    final selected = _conditionTags.contains(label);
                    return FilterChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (on) {
                        setState(() {
                          if (label == 'None noted') {
                            _conditionTags
                              ..clear()
                              ..add('None noted');
                          } else {
                            _conditionTags.remove('None noted');
                            if (on) {
                              _conditionTags.add(label);
                            } else {
                              _conditionTags.remove(label);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4F6B52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create account',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'By signing up, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 24),
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
    bool number = false,
    bool optional = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: c,
            obscureText: obscure && _obscure,
            keyboardType:
                number ? TextInputType.number : TextInputType.emailAddress,
            inputFormatters:
                number ? [FilteringTextInputFormatter.digitsOnly] : null,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: obscure
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
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
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: optional
                ? (v) {
                    if (v == null || v.trim().isEmpty) {
                      return null;
                    }
                    return validator(v);
                  }
                : validator,
          ),
        ],
      ),
    );
  }
}
