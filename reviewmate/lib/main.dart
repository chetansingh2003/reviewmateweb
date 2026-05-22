import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // ===================================
  // FIREBASE INITIALIZE
  // ===================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ===================================
  // SUPABASE INITIALIZE
  // ===================================

  await Supabase.initialize(
    url: 'https://pwaaldsnrjhexahaoqzs.supabase.co',

    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3YWFsZHNucmpoZXhhaGFvcXpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwMzIzNTksImV4cCI6MjA5NDYwODM1OX0.KdIyjjl3rfNFAuTLxlfhZDKwXvlDRPfAHYi1plSQ1Wk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}