import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  TextEditingController heightController = TextEditingController(text: "170");

  TextEditingController weightController = TextEditingController(text: "65");

  TextEditingController dateController = TextEditingController();

  double flowValue = 5;
  bool bloating = true;

  int selectedMood = 0;

  List<String> moods = ["Happy", "Irritated", "Energetic", "Calm", "Sad"];

  Set<String> symptoms = {};

  List<String> symptomsList = [
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
            /// TITLE
            const Text(
              "Nurture Your Digital Wellbeing",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// HEIGHT
            label("Height (cm)"),
            input(heightController),

            const SizedBox(height: 15),

            /// WEIGHT
            label("Weight (kg)"),
            input(weightController),

            const SizedBox(height: 25),

            /// DATE
            label("Last date of your period"),

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: inputDecoration("mm/dd/yyyy"),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  dateController.text =
                      "${picked.month}/${picked.day}/${picked.year}";
                }
              },
            ),

            const SizedBox(height: 25),

            /// FLOW
            const Text("Rate your period flow"),

            Slider(
              value: flowValue,
              min: 1,
              max: 10,
              divisions: 9,
              label: flowValue.toString(),
              onChanged: (value) {
                setState(() {
                  flowValue = value;
                });
              },
            ),

            const SizedBox(height: 20),

            /// BLOATED
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

            /// SYMPTOMS
            const Text("Symptoms"),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptomsList.map((e) {
                bool selected = symptoms.contains(e);

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

            /// MOOD
            const Text("Current Mood"),

            const SizedBox(height: 10),

            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  bool selected = selectedMood == index;

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

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile Saved")),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4F6B52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
