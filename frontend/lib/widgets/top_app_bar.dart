import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../screens/main_scaffold.dart'; // for TabSwitcher
import 'package:projectapp/screens/period_essentials.dart';

// class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
//   const TopAppBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.surface, // bg-[#fcf8ff]
//       padding: const EdgeInsets.only(
//         left: 24, // 1.5rem
//         right: 24,
//         top: 16, // 1rem
//         bottom: 16,
//       ),
//       child: SafeArea(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Avatar
//             CircleAvatar(
//               radius: 20,
//               backgroundColor: AppColors.surfaceContainerHighest,
//               child: InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SanctuaryProfileScreen(),
//                     ),
//                   );
//                 },
//                 child: Icon(
//                   Icons.person_outline,
//                   color: AppColors.onSurfaceVariant,
//                 ),
//               ),
//             ),

//             // BrandLogo
//             Text(
//               'ETHREAL',
//               style: GoogleFonts.manrope(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.onSurface,
//               ),
//             ),

//             // NotificationIcon
//             InkWell(
//               onTap: () {
//                 print('You have notification');
//               },
//               child: Icon(
//                 Icons.notifications_none_rounded,
//                 color: AppColors.onSurface,
//                 size: 24,
//               ),
//             ),
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PeriodEssentialsPage(),
//                   ),
//                 );
//               },
//               child: Icon(
//                 Icons.shopping_cart_outlined,
//                 color: AppColors.onSurface,
//                 size: 24,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight + 32);
// }
class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// LEFT + RIGHT ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  child: InkWell(
                    onTap: () {
                      final switcher = TabSwitcher.maybeOf(context);
                      if (switcher != null) {
                        switcher.switchTo(5); // Profile tab
                      }
                    },
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),

                /// Right Icons (grouped)
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        print('You have notification');
                      },
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.onSurface,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PeriodEssentialsPage(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.onSurface,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            /// CENTER TITLE (perfectly centered)
            Text(
              'FIORA',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 24);
}
