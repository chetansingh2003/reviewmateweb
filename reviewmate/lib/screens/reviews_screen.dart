// lib/screens/reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  // Correctly placed inside State — no issue with non-const initializer
  final ReviewService _reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    final String businessId = user.id;

    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: StreamBuilder<List<ReviewModel>>(
          stream: _reviewService.getReviews(businessId),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            // Empty state
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No Reviews Found',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            final reviews = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Reviews Management',
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff003D9B),
                  ),
                ),
                const SizedBox(height: 24),
                // Live reviews
                ...reviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ReviewCard(review: review),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}