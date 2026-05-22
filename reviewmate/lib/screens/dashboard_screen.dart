// ============================================
// lib/screens/dashboard_screen.dart
// ALL BUGS FIXED — CLEAN REWRITE
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reviews_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onViewAllReviews;
  const DashboardScreen({super.key, this.onViewAllReviews});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List notifications = [];
  List reviews = [];

  int totalReviews = 0;
  int positiveReviews = 0;
  int negativeReviews = 0;
  Map<String, dynamic>? profileData;

  String ownerImage = "";
  String ownerName = "";

  double averageRating = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchReviews();
    realtimeReviews();
  }

  // ===================================
  // FETCH PROFILE
  // ===================================

  Future<void> fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from("business_profiles")
          .select()
          .eq("id", user.id)
          .single();
      if (mounted) {
        setState(() {
          profileData = data;
          ownerImage = profileData?["logo"] ?? "";
          ownerName = profileData?["owner_name"] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  // ===================================
  // FETCH REVIEWS
  // ===================================

  Future<void> fetchReviews() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from("reviews")
          .select()
          .eq("business_id", user.id)
          .order("created_at", ascending: false);

      reviews = data;
      calculateStats();
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ===================================
  // REALTIME LISTENER
  // ===================================

  void realtimeReviews() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    Supabase.instance.client
        .from("reviews")
        .stream(primaryKey: ['id'])
        .eq("business_id", user.id)
        .listen((data) {
      if (data.length > reviews.length) {
        final latest = data.first;

        notifications.insert(0, {
          "name": latest["customer_name"],
          "review": latest["review"],
          "rating": latest["rating"],
          "time": "Just now",
        });

        if (mounted) {
          // NEGATIVE ALERT
          if (latest["rating"] <= 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  "Negative Review from ${latest["customer_name"]}",
                  style: GoogleFonts.inter(),
                ),
              ),
            );
          }

          // POSITIVE ALERT
          if (latest["rating"] >= 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  "New Positive Review",
                  style: GoogleFonts.inter(),
                ),
              ),
            );
          }
        }
      }

      reviews = data;
      calculateStats();
      if (mounted) {
        setState(() {});
      }
    });
  }

  // ===================================
  // CALCULATE STATS
  // ===================================

  void calculateStats() {
    totalReviews = reviews.length;
    positiveReviews = reviews.where((e) => e["rating"] >= 4).length;
    negativeReviews = reviews.where((e) => e["rating"] <= 2).length;

    if (reviews.isNotEmpty) {
      double total = 0;
      for (var review in reviews) {
        total += (review["rating"] as num).toDouble();
      }
      averageRating = total / reviews.length;
    } else {
      averageRating = 0;
    }
  }

  // ===================================
  // MAIN SCAFFOLD
  // ===================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

  backgroundColor:
  const Color(0xffFAF8FF),

  body: dashboardHome(),

  bottomNavigationBar:
  BottomNavigationBar(

    currentIndex: 0,

    selectedItemColor:
    const Color(0xff0052CC),

    unselectedItemColor:
    Colors.grey,

    type:
    BottomNavigationBarType.fixed,

    items: const [

      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: "Analytics",
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.reviews),
        label: "Reviews",
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: "Profile",
      ),
    ],

    onTap: (index) {

      if (index == 2) {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) =>
                const ReviewsScreen(),
          ),
        );
      }
    },
  ),
);
  }

  // ===================================
  // DASHBOARD HOME
  // ===================================

  Widget dashboardHome() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 28),
                  _buildAverageRatingCard(),
                  const SizedBox(height: 28),
                  _buildRecentReviews(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================
  // HEADER
  // ===================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.03),
          ),
        ],
      ),
      child: Row(
        children: [
          // AVATAR
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffE9DDFF),
              borderRadius: BorderRadius.circular(100),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundImage:
                  ownerImage.isNotEmpty ? NetworkImage(ownerImage) : null,
              child: ownerImage.isEmpty ? const Icon(Icons.person) : null,
            ),
          ),
          const SizedBox(width: 16),
          // WELCOME TEXT
          Expanded(
            child: Text(
              "Welcome, ${ownerName.isNotEmpty ? ownerName : 'User'}",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xff111827),
              ),
            ),
          ),
          // NOTIFICATION BELL
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: _showNotificationsSheet,
                icon: const Icon(
                  Icons.notifications_none,
                  size: 30,
                  color: Color(0xff4B5563),
                ),
              ),
              if (notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notifications.length.toString(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================
  // NOTIFICATIONS BOTTOM SHEET
  // ===================================

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "Live Alerts",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            notifications.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        "No alerts yet",
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return alertTile(
                        item["rating"] <= 2 ? "Negative Review" : "New Review",
                        item["review"],
                        item["rating"] <= 2 ? Colors.red : Colors.green,
                      );
                    },
                  ),
          ],
        );
      },
    );
  }

  // ===================================
  // STATS GRID
  // ===================================

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: 1.15,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        StatsCard(
          title: "$totalReviews",
          subtitle: "TOTAL REVIEWS",
          growth: "↑ 8.4%",
          growthColor: Colors.blue,
          icon: Icons.chat_bubble_outline,
          iconBg: const Color(0xffEAF2FF),
        ),
        StatsCard(
          title: "$positiveReviews",
          subtitle: "POSITIVE REVIEWS",
          growth: "↑ 12%",
          growthColor: Colors.green,
          icon: Icons.thumb_up_alt_outlined,
          iconBg: const Color(0xffEAFBF0),
        ),
        StatsCard(
          title: "$negativeReviews",
          subtitle: "NEGATIVE REVIEWS",
          growth: "↓ 1.5%",
          growthColor: Colors.red,
          icon: Icons.thumb_down_alt_outlined,
          iconBg: const Color(0xffFFECEC),
        ),
        StatsCard(
          title: averageRating.toStringAsFixed(1),
          subtitle: "AVG RATING",
          growth: "LIVE",
          growthColor: Colors.orange,
          icon: Icons.star,
          iconBg: const Color(0xffFFF8E6),
        ),
      ],
    );
  }

  // ===================================
  // AVERAGE RATING CARD
  // ===================================

  Widget _buildAverageRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.03),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Average Rating",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                averageRating.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star,
                    color: Color(0xffFFB800),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Based on $totalReviews reviews",
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================
  // RECENT REVIEWS
  // ===================================

  Widget _buildRecentReviews() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.03),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER ROW
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Feedback",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff0052CC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "LIVE UPDATES",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff0052CC),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No reviews yet",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length > 4 ? 4 : reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Column(
                  children: [
                    ReviewTile(
                      name: review["customer_name"] ?? "Anonymous",
                      time: "Recently",
                      review: review["review"] ?? "",
                      rating: review["rating"] ?? 0,
                    ),
                    const Divider(height: 1),
                  ],
                );
              },
            ),

          // =================================
          // LOAD MORE BUTTON
          // =================================

          if (reviews.length > 4)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0052CC),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                 onPressed: () {

  if (widget.onViewAllReviews != null) {

    widget.onViewAllReviews!();

  } else {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const ReviewsScreen(),
      ),
    );
  }
},
                  child: Text(
                    "Load More Reviews",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===================================
  // HELPER WIDGETS
  // ===================================

  Widget alertTile(String title, String subtitle, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(Icons.notifications, color: color),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
    );
  }

  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xff111827),
          ),
        ),
      ),
    );
  }

  Widget buildInsightRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xff1f2937),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// STATS CARD
// ============================================

class StatsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String growth;
  final Color growthColor;
  final IconData icon;
  final Color iconBg;

  const StatsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.growth,
    required this.growthColor,
    required this.icon,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.03),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: growthColor),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  growth,
                  style: GoogleFonts.inter(
                    color: growthColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// REVIEW TILE
// ============================================

class ReviewTile extends StatelessWidget {
  final String name;
  final String time;
  final String review;
  final int rating;

  const ReviewTile({
    super.key,
    required this.name,
    required this.time,
    required this.review,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    rating,
                    (index) => const Icon(
                      Icons.star,
                      size: 18,
                      color: Color(0xffFFB800),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  review,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
