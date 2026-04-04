// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../theme/app_colors.dart';

// class AiScreen extends StatelessWidget {
//   const AiScreen({super.key});

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
//           const SizedBox(height: 12),

//           // AI Title Section
//           Text(
//             'AI Sanctuary',
//             style: GoogleFonts.manrope(
//               fontSize: 48,
//               fontWeight: FontWeight.w700,
//               color: AppColors.onSurface,
//             ),
//           ),
//           const SizedBox(height: 12),

//           // Disclaimer/Label Section
//           Text(
//             "AI may provide insights based on your health data. Consult a professional for medical advice.",
//             style: GoogleFonts.manrope(
//               fontSize: 14,
//               color: AppColors.onSurfaceVariant,
//             ),
//           ),

//           const SizedBox(height: 48),

//           // Daily Focus Section (Headline MD)
//           Text(
//             'Daily Focus',
//             style: GoogleFonts.manrope(
//               fontSize: 28,
//               fontWeight: FontWeight.w600,
//               color: AppColors.onSurface,
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Focus 1: Completed (Tonal Shift - Pale Green)
//           _buildFocusCard(
//             'Green Tea Ritual',
//             'Completed 8:00 AM',
//             Icons.done_all,
//             AppColors.primaryFixed,
//             AppColors.primary,
//           ),
//           const SizedBox(height: 16),

//           // Focus 2: Upcoming (Tonal Shift - Recessed beige)
//           _buildFocusCard(
//             'Meditation Session',
//             'Upcoming 4:00 PM',
//             Icons.self_improvement,
//             AppColors.surfaceContainerLow,
//             AppColors.tertiary,
//           ),
//           const SizedBox(height: 16),

//           // Focus 3: Content Highlight
//           _buildFocusCard(
//             'The Science of Evening Rituals',
//             'New Article Available',
//             Icons.menu_book,
//             AppColors.surfaceContainer,
//             AppColors.onSurface,
//           ),

//           const SizedBox(height: 60),

//           // AI Interaction Bar: surface-container-highest (pill)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             decoration: BoxDecoration(
//               color: AppColors.surfaceContainerHighest,
//               borderRadius: BorderRadius.circular(9999),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Ask your AI Guide anything...',
//                     style: GoogleFonts.manrope(
//                       fontSize: 16,
//                       color: AppColors.onSurfaceVariant,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: const BoxDecoration(
//                     color: AppColors.primary,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.send_rounded,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 120),
//         ],
//       ),
//     );
//   }

//   Widget _buildFocusCard(
//     String title,
//     String status,
//     IconData icon,
//     Color bgColor,
//     Color iconColor,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(28),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(40),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.5),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: iconColor, size: 28),
//           ),
//           const SizedBox(width: 24),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: GoogleFonts.manrope(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   status,
//                   style: GoogleFonts.manrope(
//                     fontSize: 14,
//                     color: AppColors.onSurfaceVariant,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: 16,
              ),
              children: const [
                _AiBubble(),
                SizedBox(height: 16),
                _SuggestionChips(),
                SizedBox(height: 24),
                _UserBubble(),
                SizedBox(height: 24),
                _TypingIndicator(),
              ],
            ),
          ),
          const _ChatInput(),
        ],
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "FIORA AI",
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurface.withOpacity(.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            "Hello! I've analyzed your recent wellness patterns. It looks like your sleep quality improved by 12% last night. Would you like to explore why that might be, or should we plan your mindfulness session for today?",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _Chip(label: "Explain this improvement"),
        _Chip(label: "Plan my session"),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(.2)),
      ),
      child: Text(label),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          "I think the new evening tea ritual helped a lot. Can you tell me more about the ingredients in the blend I used?",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "FIORA AI IS THINKING",
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurface.withOpacity(.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [_Dot(), _Dot(), _Dot()],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.05)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Message your Fiora AI...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
