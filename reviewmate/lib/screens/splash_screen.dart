import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
      () async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
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
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
              );
            }
          } catch (e) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
              );
            }
          }
        } else {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold(

      body: Center(
        child: FlutterLogo(size: 100),
      ),
    );
  }
}