// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../utils/colors.dart';
// import '../routes/app_router.dart';

// class AppBottomNav extends StatelessWidget {
//   final int currentIndex;
//   const AppBottomNav({super.key, this.currentIndex = 0});

//   void _onTap(BuildContext context, int index) {
//     switch (index) {
//       case 0:
//         Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.home, (r) => false);
//         break;
//       case 1:
//         Navigator.of(context).pushNamed(AppRouter.support);
//         break;
//       case 2:
//         Navigator.of(context).pushNamed(AppRouter.incomeReport);
//         break;
//       case 3:
//         Navigator.of(context).pushNamed(AppRouter.profile);
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       currentIndex: currentIndex,
//       onTap: (i) => _onTap(context, i),
//       selectedItemColor: AppColors.brand,
//       unselectedItemColor: Colors.grey,
//       selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
//       unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
//         BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
//         BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Reports'),
//         BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
//       ],
//     );
//   }
// }
