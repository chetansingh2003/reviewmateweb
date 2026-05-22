// ==========================================================
// FILE: lib/screens/profile_screen.dart
// REVIEWMATE PROFILE SCREEN - FIXED & CLEAN VERSION
// ==========================================================

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notification = true;
  bool darkMode = false;
  String selectedLanguage = "English";
  File? profileImage;
  Map<String, dynamic>? profileData;

  bool loading = true;
  Future<void> getProfileData() async {

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      final data = await Supabase.instance.client
          .from("business_profiles")
          .select()
          .eq("id", user.id)
          .maybeSingle();

      if (data != null) {
        setState(() {
          profileData = data;
          ownerController.text = data["owner_name"] ?? "";
          categoryController.text = data["category"] ?? "";
          linkController.text = data["google_review_link"] ?? "";
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading profile: $e")),
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

  Future<void> saveChanges() async {
    try {
      setState(() {
        loading = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "User not logged in";

      String imageUrl = profileData?["logo"] ?? "";

      if (profileImage != null) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        await Supabase.instance.client.storage
            .from('business-logos')
            .upload(
              fileName,
              profileImage!,
            );
        imageUrl = Supabase.instance.client.storage
            .from('business-logos')
            .getPublicUrl(fileName);
      }

      await Supabase.instance.client
          .from("business_profiles")
          .upsert({
        "id": user.id,
        "business_name": profileData?["business_name"] ?? "",
        "owner_name": ownerController.text.trim(),
        "category": categoryController.text.trim(),
        "google_review_link": linkController.text.trim(),
        "logo": imageUrl,
        "email": user.email,
      });

      await getProfileData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
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

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  final ownerController = TextEditingController();
  final categoryController = TextEditingController();
  final linkController = TextEditingController();

  // =====================================================
  // PICK IMAGE
  // =====================================================

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode
          ? const Color(0xff0F172A)
          : const Color(0xffF8FAFC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: 120,
          ),

          child: Column(
            children: [
              // ==============================================
              // HEADER
              // ==============================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff0052CC),
                              Color(0xff3B82F6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "ReviewMate",
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: darkMode
                              ? Colors.white
                              : const Color(0xff003D9B),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: darkMode
                        ? const Color(0xff1E293B)
                        : Colors.white,
                    child: Icon(
                      Icons.settings,
                      color: darkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==============================================
              // PROFILE CARD
              // ==============================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: darkMode
                      ? const Color(0xff111827)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ----------------------------------------
                    // PROFILE IMAGE
                    // ----------------------------------------

                    GestureDetector(
                      onTap: pickImage,
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xff0052CC),
                                  Color(0xff3B82F6),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: profileImage != null
                                  ? FileImage(profileImage!) as ImageProvider
                                  : (profileData?["logo"] != null && profileData!["logo"].toString().isNotEmpty
                                      ? NetworkImage(profileData!["logo"])
                                      : const NetworkImage("https://i.pravatar.cc/300")),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xff0052CC),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      profileData?["business_name"] ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffE8F0FF),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: Color(0xff0052CC),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Verified",
                            style: GoogleFonts.inter(
                              color: const Color(0xff0052CC),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      profileData?["category"] ?? "",
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(child: topButton(Icons.public, "View")),
                        const SizedBox(width: 12),
                        Expanded(child: topButton(Icons.share, "Share")),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==============================================
              // BUSINESS INFO
              // ==============================================

              sectionCard(
                title: "Business Information",
                icon: Icons.store,
                child: Column(
                  children: [
                    inputField("Owner Name", ownerController),
                    const SizedBox(height: 18),
                    inputField("Business Category", categoryController),
                    const SizedBox(height: 18),
                    inputField("Google Review Link", linkController, copy: true),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==============================================
              // PREFERENCES
              // ==============================================

              sectionCard(
                title: "Preferences",
                icon: Icons.tune,
                child: Column(
                  children: [
                    // LANGUAGE
                    Row(
                      children: [
                        const Icon(Icons.language, color: Colors.grey),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Language",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedLanguage,
                          underline: const SizedBox(),
                          items: ["English", "Hindi", "French"]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() => selectedLanguage = v!);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // DARK MODE
                    Row(
                      children: [
                        const Icon(Icons.dark_mode, color: Colors.grey),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Dark Mode",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Switch(
                          value: darkMode,
                          activeColor: const Color(0xff0052CC),
                          onChanged: (v) => setState(() => darkMode = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // NOTIFICATIONS
                    Row(
                      children: [
                        const Icon(Icons.notifications, color: Colors.grey),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Notifications",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Switch(
                          value: notification,
                          activeColor: const Color(0xff0052CC),
                          onChanged: (v) => setState(() => notification = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==============================================
              // CLOUD STORAGE
              // ==============================================

              sectionCard(
                title: "Cloud Storage",
                icon: Icons.cloud,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Storage Used",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "65%",
                          style: GoogleFonts.inter(
                            color: const Color(0xff0052CC),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(
                        value: 0.65,
                        minHeight: 8,
                        backgroundColor: Color(0xffE0E0E0),
                        valueColor: AlwaysStoppedAnimation(Color(0xff0052CC)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "3.2GB / 5GB Used",
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==============================================
              // SUBSCRIPTION
              // ==============================================

              sectionCard(
                title: "Subscription",
                icon: Icons.workspace_premium,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff0052CC), Color(0xff3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "PREMIUM PLAN",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Text(
                              "ACTIVE",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Unlimited QR reviews, AI replies, analytics & cloud sync.",
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xff0052CC),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Upgrade page coming soon"),
                              ),
                            );
                          },
                          child: Text(
                            "Manage Subscription",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ==============================================
              // HELP & SUPPORT
              // ==============================================

              sectionCard(
                title: "Help & Support",
                icon: Icons.support_agent,
                child: Column(
                  children: [
                    supportTile(Icons.help_center, "Help Center", "FAQs & Tutorials"),
                    const Divider(),
                    supportTile(Icons.chat, "Live Chat Support", "Talk with support team"),
                    const Divider(),
                    supportTile(Icons.email, "Email Support", "support@reviewmate.ai"),
                    const Divider(),
                    supportTile(Icons.bug_report, "Report a Problem", "Send app issue report"),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==============================================
              // PRIVACY & LEGAL
              // ==============================================

              sectionCard(
                title: "Privacy & Legal",
                icon: Icons.privacy_tip,
                child: Column(
                  children: [
                    supportTile(Icons.lock, "Privacy Policy", "Read privacy policy"),
                    const Divider(),
                    supportTile(Icons.description, "Terms & Conditions", "Read terms and conditions"),
                    const Divider(),
                    supportTile(Icons.security, "Data Security", "Your data is encrypted"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==============================================
              // SAVE BUTTON
              // ==============================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0052CC),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: loading ? null : saveChanges,
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Save Changes",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ==============================================
              // LOGOUT BUTTON
              // ==============================================

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text(
                          "Are you sure you want to logout?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              navigator.pop();
                              await Supabase.instance.client.auth.signOut();
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    "Sign Out",
                    style: GoogleFonts.inter(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // HELPER WIDGETS
  // =====================================================

  Widget topButton(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xff111827) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Colors.black.withOpacity(0.03),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xff0052CC)),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: darkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    bool copy = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(
            color: darkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: darkMode
                ? const Color(0xff1E293B)
                : const Color(0xffFAFBFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: copy
                ? IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: controller.text),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Link copied")),
                      );
                    },
                    icon: const Icon(Icons.copy),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  // FIX: supportTile moved INSIDE the class so it can access darkMode & context
  Widget supportTile(IconData icon, String title, String subtitle) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title clicked")),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xffE8F0FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xff0052CC)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}