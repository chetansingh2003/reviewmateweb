class ReviewModel {

  final String id;
  final String customerName;
  final String review;
  final int rating;
  final String platform;
  final String qrId;
  final String businessId;
  final bool replied;
  final String reply;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.customerName,
    required this.review,
    required this.rating,
    required this.platform,
    required this.qrId,
    required this.businessId,
    required this.replied,
    required this.reply,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(
      Map<String, dynamic> data,
      String id,
      ) {

    return ReviewModel(
      id: id,
      customerName: data['customer_name'] ?? data['customerName'] ?? "",
      review: data['review'] ?? "",
      rating: data['rating'] ?? 0,
      platform: data['platform'] ?? "",
      qrId: data['qr_id'] ?? data['qrId'] ?? "",
      businessId: data['business_id'] ?? data['businessId'] ?? "",
      replied: data['replied'] ?? false,
      reply: data['reply'] ?? "",
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : (data['createdAt'] != null
              ? DateTime.parse(data['createdAt'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {

    return {
      'customer_name': customerName,
      'review': review,
      'rating': rating,
      'platform': platform,
      'qr_id': qrId,
      'business_id': businessId,
      'replied': replied,
      'reply': reply,
      'created_at': createdAt.toIso8601String(),
    };
  }
}