// import 'package:flutter/material.dart';

// class LearnScreen extends StatefulWidget {
//   const LearnScreen({super.key});

//   @override
//   State<LearnScreen> createState() => _LearnScreenState();
// }

// class _LearnScreenState extends State<LearnScreen> {
//   /// CARD PAGE
//   final PageController _pageController = PageController();
//   int currentPage = 0;

//   /// QUIZ
//   int selectedAnswer = -1;
//   int score = 8;
//   int questionIndex = 0;

//   final questions = [
//     "What is the follicular phase?",
//     "Which hormone rises before ovulation?",
//     "When does progesterone peak?",
//   ];

//   final answers = [
//     [
//       "The time from day one of your period to ovulation",
//       "The phase where hormone levels are highest",
//       "The week before your menstrual cycle begins",
//       "A period of deep rest",
//     ],
//     ["Estrogen", "Progesterone", "Testosterone", "Cortisol"],
//     ["Follicular phase", "Ovulation", "Luteal phase", "Menstrual phase"],
//   ];

//   final correctAnswers = [0, 0, 2];
//   void submitQuiz() {
//     if (selectedAnswer == correctAnswers[questionIndex]) {
//       score++;
//     }

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Quiz Completed 🎉"),
//         content: Text("Your Score: $score / ${questions.length}"),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   void nextQuestion() {
//     SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: selectedAnswer == -1
//             ? null
//             : questionIndex == questions.length - 1
//             ? submitQuiz
//             : nextQuestion,
//         child: Text(
//           questionIndex == questions.length - 1 ? "Submit" : "Next Question",
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF7F4EF),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _header(),

//               const SizedBox(height: 20),

//               _title(),

//               const SizedBox(height: 24),

//               _swipeCards(),

//               const SizedBox(height: 28),

//               _questionCard(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// HEADER
//   Widget _header() {
//     return Row(
//       children: const [
//         CircleAvatar(radius: 16),
//         SizedBox(width: 10),
//         Text("THE SANCTUARY", style: TextStyle(letterSpacing: 2, fontSize: 12)),
//         Spacer(),
//         Icon(Icons.menu_book_outlined),
//       ],
//     );
//   }

//   /// TITLE
//   Widget _title() {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Cultivate Your Mind: Daily\nReflections",
//           style: TextStyle(fontSize: 28, height: 1.2),
//         ),

//         SizedBox(height: 8),

//         Text(
//           "Take a breath. Each card is a step in your journey.",
//           style: TextStyle(color: Colors.grey),
//         ),
//       ],
//     );
//   }

//   /// SWIPE CARDS
//   Widget _swipeCards() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               "MINDFUL INSIGHTS",
//               style: TextStyle(letterSpacing: 2, fontSize: 11),
//             ),
//             Text("${currentPage + 1} / 3"),
//           ],
//         ),

//         const SizedBox(height: 12),

//         SizedBox(
//           height: 320,
//           child: PageView(
//             controller: _pageController,
//             onPageChanged: (index) {
//               setState(() {
//                 currentPage = index;
//               });
//             },
//             children: [
//               _card("assets/learn.png", "Hormones 101"),
//               _card("assets/learn.png", "Cycle Phases"),
//               _card("assets/learn.png", "Ovulation Guide"),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _card(String image, String title) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(28),
//         image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(28),
//           gradient: LinearGradient(
//             begin: Alignment.bottomCenter,
//             end: Alignment.center,
//             colors: [Colors.black.withOpacity(.6), Colors.transparent],
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(color: Colors.white, fontSize: 26),
//             ),

//             const SizedBox(height: 6),

//             const Text(
//               "Decoding the chemical messengers of your body.",
//               style: TextStyle(color: Colors.white70),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// QUESTION CARD
//   Widget _questionCard() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "REFLECT ON YOUR UNDERSTANDING",
//           style: TextStyle(letterSpacing: 2, fontSize: 11),
//         ),

//         const SizedBox(height: 12),

//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(28),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "QUESTION ${questionIndex + 1} OF ${questions.length}",
//                     style: const TextStyle(
//                       color: Colors.deepPurple,
//                       fontSize: 11,
//                     ),
//                   ),
//                   Text("SCORE: $score"),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               Text(
//                 questions[questionIndex],
//                 style: const TextStyle(fontSize: 18),
//               ),

//               const SizedBox(height: 20),

//               Column(
//                 children: List.generate(answers[questionIndex].length, (index) {
//                   final selected = selectedAnswer == index;

//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedAnswer = index;
//                       });
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30),
//                         border: Border.all(
//                           color: selected
//                               ? Colors.deepPurple
//                               : Colors.grey.shade300,
//                         ),
//                       ),
//                       child: Text(
//                         answers[questionIndex][index],
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   );
//                 }),
//               ),

//               const SizedBox(height: 12),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: selectedAnswer == -1 ? null : nextQuestion,
//                   child: const Text("Next Question"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  /// swipe cards
  final PageController _pageController = PageController();
  int currentPage = 0;
  bool quizCompleted = false;

  /// quiz
  int selectedAnswer = -1;
  int score = 0;
  int questionIndex = 0;

  final questions = [
    "What is the follicular phase?",
    "Which hormone rises before ovulation?",
    "When does progesterone peak?",
    "Which nutrient is most critical for preventing anemia in menstruating women?",
    "What is the primary function of the endometrium?",
    "How long does the average menstrual cycle typically last?",
    "Which hormone is responsible for the thickening of the uterine lining?",
    "What is the term for the release of an egg from the ovary?",
    "Which type of sanitary product is reusable and inserted into the vagina?",
    "What is the average amount of blood lost during a menstrual period?",
    "Which phase occurs after ovulation and before menstruation?",
    "What is the main symptom of PMS (Premenstrual Syndrome)?",
    "Which mineral helps regulate mood and reduce bloating during PMS?",
    "What is the medical term for the absence of menstruation?",
  ];

  final answers = [
    [
      "The time from day one of your period to ovulation",
      "The phase where hormone levels are highest",
      "The week before your menstrual cycle begins",
      "A period of deep rest",
    ],
    ["Estrogen", "Progesterone", "Testosterone", "Cortisol"],
    ["Follicular phase", "Ovulation", "Luteal phase", "Menstrual phase"],
    ["Calcium", "Iron", "Vitamin D", "Magnesium"],
    [
      "To shed the uterine lining",
      "To release an egg",
      "To produce hormones",
      "To prepare for pregnancy",
    ],
    ["28 days", "30 days", "35 days", "20 days"],
    ["Estrogen", "Progesterone", "Testosterone", "LH"],
    ["Ovulation", "Menstruation", "Luteal phase", "Follicular phase"],
    ["Menstrual cup", "Tampon", "Panty liner", "Pad"],
    [
      "1-2 tablespoons",
      "3-4 tablespoons",
      "5-6 tablespoons",
      "7-8 tablespoons",
    ],
    ["Luteal phase", "Menstrual phase", "Ovulation", "Follicular phase"],
    [
      "Post Menstrual Syndrome",
      "Premenstrual Syndrome",
      "Period Mood Syndrome",
      "Pre Menstrual Signal",
    ],
    ["Mood swings", "Cramps", "Bloating", "All of the above"],
    ["Magnesium", "Calcium", "Vitamin D", "Iron"],
    //["Dysmenorrhea", "Endometriosis", "PCOS", "Amenorrhea"],
  ];

  final correctAnswers = [0, 0, 2, 1, 3, 0, 0, 0, 1, 1, 0, 3, 0, 3];

  void nextQuestion() {
    if (selectedAnswer == correctAnswers[questionIndex]) {
      score++;
    }

    setState(() {
      questionIndex++;
      selectedAnswer = -1;
    });
  }

  void submitQuiz() {
    if (selectedAnswer == correctAnswers[questionIndex]) {
      score++;
      setState(() {
        quizCompleted = true;
      });
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Quiz Completed 🎉"),
        content: Text(
          "Your Score: $score / ${questions.length}",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF7F4EF),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),

              const SizedBox(height: 20),

              _title(),

              const SizedBox(height: 24),

              _swipeCards(),

              const SizedBox(height: 28),

              _questionCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// HEADER
  Widget _header() {
    return Row(
      children: [
        CircleAvatar(radius: 20, child: Icon(Icons.spa)),
        SizedBox(width: 10),
        Text("Fiora", style: TextStyle(letterSpacing: 2, fontSize: 18)),
        Spacer(),
        InkWell(
          onTap: () {
            print("Menu clicked");
            //Navigator.push(context, MaterialPageRoute(builder: (context) => const LearnScreen()));
          },
          child: Icon(Icons.menu_book_outlined),
        ),
      ],
    );
  }

  /// TITLE
  Widget _title() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cultivate Your Mind: Daily Reflections",
          style: TextStyle(fontSize: 28, height: 1.2),
        ),

        SizedBox(height: 8),

        Text(
          "Take a breath. Each card is a step in your journey.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  /// SWIPE CARDS
  Widget _swipeCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "MINDFUL INSIGHTS",
              style: TextStyle(letterSpacing: 2, fontSize: 11),
            ),
            Text("${currentPage + 1} / 3"),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 320,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: [
              _card("assets/learn.png", "Hormones 101"),
              _card("assets/learn.png", "Cycle Phases"),
              _card("assets/learn.png", "Ovulation Guide"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card(String image, String title) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black.withOpacity(.6), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 26),
            ),

            const SizedBox(height: 6),

            const Text(
              "Decoding the chemical messengers of your body.",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Text(
            "Quiz Completed 🎉",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          Text("Your Score", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 8),

          Text(
            "$score / ${questions.length}",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              setState(() {
                quizCompleted = false;
                score = 0;
                questionIndex = 0;
                selectedAnswer = -1;
              });
            },
            child: const Text("Restart Quiz"),
          ),
        ],
      ),
    );
  }

  /// QUESTION CARD
  Widget _questionCard() {
    if (quizCompleted) {
      return _resultCard();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "REFLECT ON YOUR UNDERSTANDING",
          style: TextStyle(letterSpacing: 2, fontSize: 11),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "QUESTION ${questionIndex + 1} OF ${questions.length}",
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 11,
                    ),
                  ),
                  Text("SCORE: $score"),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                questions[questionIndex],
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 20),

              Column(
                children: List.generate(answers[questionIndex].length, (index) {
                  final selected = selectedAnswer == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAnswer = index;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected
                              ? Colors.deepPurple
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        answers[questionIndex][index],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAnswer == -1
                      ? null
                      : questionIndex == questions.length - 1
                      ? submitQuiz
                      : nextQuestion,
                  child: Text(
                    questionIndex == questions.length - 1
                        ? "Submit"
                        : "Next Question",
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
