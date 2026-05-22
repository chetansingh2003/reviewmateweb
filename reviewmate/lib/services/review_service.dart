import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/review_model.dart';

class ReviewService {

  // ==========================================
  // REALTIME REVIEWS
  // ==========================================

  Stream<List<ReviewModel>>
  getReviews(String businessId) {

    return Supabase.instance.client
        .from('reviews')
        .stream(primaryKey: ['id'])
        .eq('business_id', businessId)
        .order('created_at', ascending: false)
        .map((maps) {

      return maps.map((map) {

        return ReviewModel.fromMap(map, map['id'].toString());

      }).toList();
    });
  }

  // ==========================================
  // ADD REVIEW
  // ==========================================

  Future<void> addReview({
    required String customerName,
    required String review,
    required int rating,
    required String qrId,
    required String businessId,
  }) async {

    await Supabase.instance.client
        .from('reviews')
        .insert({

      'customer_name': customerName,

      'review': review,

      'rating': rating,

      'platform': 'Google',

      'qr_id': qrId,

      'business_id': businessId,

      'replied': false,

      'reply': "",

      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================
  // REPLY REVIEW
  // ==========================================

  Future<void> replyReview({
    required String reviewId,
    required String reply,
  }) async {

    await Supabase.instance.client
        .from('reviews')
        .update({

      'replied': true,
      'reply': reply,
    })
        .eq('id', reviewId);
  }
}