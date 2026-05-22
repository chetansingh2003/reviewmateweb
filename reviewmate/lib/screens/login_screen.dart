import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  bool loading = false;

  @override
  void initState() {
    super.initState();

    // ===================================
    // AUTH LISTENER
    // ===================================

    Supabase.instance.client.auth
        .onAuthStateChange
        .listen((data) async {

      final session = data.session;

      if (session != null && mounted) {
        setState(() {
          loading = true;
        });

        try {
          final profile = await Supabase.instance.client
              .from('business_profiles')
              .select()
              .eq('id', session.user.id)
              .maybeSingle();

          if (!mounted) return;

          if (profile != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileSetupScreen(),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileSetupScreen(),
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
        }
      }
    });
  }

  // ===================================
  // GOOGLE LOGIN
  // ===================================

  Future<void> signInWithGoogle() async {

    try {

      setState(() {
        loading = true;
      });

      final response = await AuthService.signInWithGoogle();

      if (response == null) {
        await Supabase.instance.client.auth
            .signInWithOAuth(
          OAuthProvider.google,
          redirectTo:
          'io.supabase.flutterquickstart://login-callback/',
        );
      }

    } catch (e) {

      try {
        await Supabase.instance.client.auth
            .signInWithOAuth(
          OAuthProvider.google,
          redirectTo:
          'io.supabase.flutterquickstart://login-callback/',
        );
      } catch (oauthError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(oauthError.toString()),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xfff5f7ff),
              Color(0xffffffff),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(

          child: Center(

            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  const Icon(
                    Icons.business,
                    size: 80,
                    color: Color(0xff0052cc),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "ReviewMate",

                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color:
                      const Color(0xff0052cc),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Manage your business & track daily reviews effortlessly",

                    textAlign: TextAlign.center,

                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "The high-performance dashboard for modern reputation management.",

                    textAlign: TextAlign.center,

                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 40),

                  InkWell(

                    onTap: signInWithGoogle,

                    child: Container(

                      width: double.infinity,

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 18,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(18),

                        border: Border.all(
                          color:
                          Colors.grey.shade300,
                        ),

                        boxShadow: [
                          BoxShadow(
                            blurRadius: 15,
                            color: Colors.black
                                .withOpacity(0.05),
                          )
                        ],
                      ),

                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [

                          Image.network(
                            'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                            height: 28,
                          ),

                          const SizedBox(width: 15),

                          loading
                              ? const CircularProgressIndicator()
                              : Text(
                                  "Continue with Google",

                                  style:
                                  GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [

                      statsCard(
                        "12k+",
                        "Businesses",
                      ),

                      const SizedBox(width: 20),

                      statsCard(
                        "4.9/5",
                        "Rating",
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Text(
                    "© 2026 ReviewMate",

                    style: GoogleFonts.inter(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================================
  // STATS CARD
  // ===================================

  Widget statsCard(
      String title,
      String subtitle,
      ) {

    return Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color:
            Colors.black.withOpacity(0.04),
          )
        ],
      ),

      child: Column(
        children: [

          Text(
            title,

            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0052cc),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,

            style: GoogleFonts.inter(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}