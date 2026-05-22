// =======================================================
// FILE: lib/screens/home_screen.dart
// =======================================================

import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'reviews_screen.dart';
import 'qr_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  int currentIndex = 0;

  // ==========================================
  // PAGES
  // ==========================================

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      DashboardScreen(
        onViewAllReviews: () {
          setState(() {
            currentIndex = 1;
          });
        },
      ),

      // REVIEWS SCREEN
      ReviewsScreen(),

      // QR SCREEN
      const QrScreen(),

      // PROFILE SCREEN
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[currentIndex],

      // ======================================
      // BOTTOM NAVIGATION
      // ======================================

      bottomNavigationBar: Container(

        height: 85,

        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color:
              Colors.black.withOpacity(
                0.05,
              ),
            )
          ],
        ),

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceAround,

          children: [

            // ==================================
            // DASHBOARD
            // ==================================

            navItem(
              icon:
              Icons.dashboard_rounded,

              title: "Dashboard",

              index: 0,
            ),

            // ==================================
            // REVIEWS
            // ==================================

            navItem(
              icon:
              Icons.reviews_rounded,

              title: "Reviews",

              index: 1,
            ),

            // ==================================
            // QR BUTTON
            // ==================================

            GestureDetector(

              onTap: () {

                setState(() {
                  currentIndex = 2;
                });
              },

              child: AnimatedContainer(

                duration:
                const Duration(
                  milliseconds: 250,
                ),

                padding:
                const EdgeInsets.all(
                  14,
                ),

                decoration: BoxDecoration(

                  gradient:
                  const LinearGradient(
                    colors: [
                      Color(0xff0052CC),
                      Color(0xff3B82F6),
                    ],
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    22,
                  ),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 22,

                      color:
                      const Color(
                        0xff0052CC,
                      ).withOpacity(0.35),
                    )
                  ],
                ),

                child: const Icon(
                  Icons.qr_code_2_rounded,

                  color: Colors.white,

                  size: 30,
                ),
              ),
            ),

            // ==================================
            // PROFILE
            // ==================================

            navItem(
              icon:
              Icons.person_rounded,

              title: "Profile",

              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // NAV ITEM
  // ==========================================

  Widget navItem({
    required IconData icon,
    required String title,
    required int index,
  }) {

    final bool active =
        currentIndex == index;

    return GestureDetector(

      onTap: () {

        setState(() {
          currentIndex = index;
        });
      },

      child: AnimatedContainer(

        duration:
        const Duration(
          milliseconds: 300,
        ),

        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: active
              ? const Color(
            0xff0052CC,
          ).withOpacity(0.1)
              : Colors.transparent,

          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [

            Icon(
              icon,

              color: active
                  ? const Color(
                0xff0052CC,
              )
                  : Colors.grey,
            ),

            const SizedBox(height: 5),

            Text(
              title,

              style: TextStyle(
                fontSize: 12,

                fontWeight:
                FontWeight.w700,

                color: active
                    ? const Color(
                  0xff0052CC,
                )
                    : Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}