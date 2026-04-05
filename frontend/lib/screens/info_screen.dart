import 'package:flutter/material.dart';

import '../services/fiora_api.dart';

/// InfoPage — collects period health data after signup and PATCHes it to
/// the backend via PATCH /profiles/me.
///
/// FIX: Previously the "Save Profile" button called
///   Navigator.pushNamedAndRemoveUntil(context, '/home', ...)
/// immediately, without any API call. This meant the user's height, weight,
/// last period date, flow, symptoms and mood were thrown away and never
/// reached the database.
///
/// Now:
///  1. We build a patch payload from every field.
///  2. We call FioraApi().patchProfileInfo(...) which hits PATCH /api/v1/profiles/me.
///  3. Only on success do we navigate to /home.
///  4. Errors are shown in a SnackBar so the user knows something went wrong.
class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final TextEditingController heightController =
      TextEditingController(text: "170");
  final TextEditingController weightController =
      TextEditingController(text: "65");
  final TextEditingController dateController = TextEditingController();

  double flowValue = 5;
  bool bloating = true;
  int selectedMood = 0;
  bool _saving = false;

  // Raw DateTime so we can send ISO-8601 to the backend.
  DateTime? _lastPeriodDate;

  final List<String> moods = ["Happy", "Irritated", "Energetic", "Calm", "Sad"];

  Set<String> symptoms = {};

  final List<String> symptomsList = [
    "Everything is fine",
    "Cramps",
    "Tender breasts",
    "Headache",
    "Acne",
    "Backache",
    "Fatigue",
    "Cravings",
    "Insomnia",
    "Abdominal pain",
    "Vaginal dryness",
    "Hot flashes",
  ];

  final _api = FioraApi();

  Future<void> _saveProfile() async {
    if (_saving) return;
    setState(() => _saving = true);

    // Build symptom list (include bloating if selected)
    final List<String> allSymptoms = [
      ...symptoms,
      if (bloating) 'Bloating',
    ];

    try {
      await _api.patchProfileInfo(
        heightCm: double.tryParse(heightController.text.trim()),
        weightKg: double.tryParse(weightController.text.trim()),
        lastPeriodDateIso: _lastPeriodDate != null
            ? "${_lastPeriodDate!.year.toString().padLeft(4, '0')}-"
                "${_lastPeriodDate!.month.toString().padLeft(2, '0')}-"
                "${_lastPeriodDate!.day.toString().padLeft(2, '0')}"
            : null,
        flowRating: flowValue.round(),
        mood: moods[selectedMood],
        symptoms: allSymptoms,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved ✓")),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FioraApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save failed (${e.statusCode}): ${e.body}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F4F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Personal Health Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nurture Your Digital Wellbeing",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            label("Height (cm)"),
            input(heightController),

            const SizedBox(height: 15),

            label("Weight (kg)"),
            input(weightController),

            const SizedBox(height: 25),

            label("Last date of your period"),

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: inputDecoration("mm/dd/yyyy"),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _lastPeriodDate = picked;
                    dateController.text =
                        "${picked.month}/${picked.day}/${picked.year}";
                  });
                }
              },
            ),

            const SizedBox(height: 25),

            const Text("Rate your period flow"),

            Slider(
              value: flowValue,
              min: 1,
              max: 10,
              divisions: 9,
              label: flowValue.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  flowValue = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text("Did you experience bloating?"),

            Row(
              children: [
                choiceButton("YES", bloating, () {
                  setState(() => bloating = true);
                }),
                const SizedBox(width: 10),
                choiceButton("NO", !bloating, () {
                  setState(() => bloating = false);
                }),
              ],
            ),

            const SizedBox(height: 25),

            const Text("Symptoms"),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptomsList.map((e) {
                final bool selected = symptoms.contains(e);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selected ? symptoms.remove(e) : symptoms.add(e);
                    });
                  },
                  child: Chip(
                    label: Text(e),
                    backgroundColor: selected
                        ? Colors.green.shade200
                        : Colors.grey.shade200,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            const Text("Current Mood"),

            const SizedBox(height: 10),

            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final bool selected = selectedMood == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMood = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.green.shade200
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_emotions),
                          Text(moods[index]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            /// FIX: was  onPressed: () { Navigator.pushNamedAndRemoveUntil... }
            /// Now calls _saveProfile() which sends data to PATCH /profiles/me.
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4F6B52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "SAVE PROFILE",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text),
    );
  }

  Widget input(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: inputDecoration(""),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Widget choiceButton(String text, bool selected, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade300 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text),
      ),
    );
  }
}
