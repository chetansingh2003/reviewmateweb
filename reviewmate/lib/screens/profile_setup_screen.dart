// ==========================================================
// FILE: lib/screens/profile_setup_screen.dart
// ==========================================================

import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}
class _ProfileSetupScreenState
    extends State<ProfileSetupScreen> {

  bool loading = false;

  final businessNameController =
      TextEditingController();

  final ownerNameController =
      TextEditingController();

  final googleLinkController =
      TextEditingController();

  String selectedCategory = "";

  File? image;

  final List<String> categories = [

    "Professional Services",
    "Retail & E-commerce",
    "Healthcare",
    "Real Estate",
    "Hospitality",
    "Cafe",
    "Hotel",
    "Salon",
    "Medical Store",
    "Gym",
  ];

  // =========================================
  // SUPABASE IMAGE UPLOAD
  // =========================================

  Future<String> uploadImageToSupabase(
      File imageFile) async {

    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}.jpg";

    await Supabase.instance.client.storage
        .from('business-logos')
        .upload(
          fileName,
          imageFile,
        );

    final imageUrl =
        Supabase.instance.client.storage
            .from('business-logos')
            .getPublicUrl(fileName);

    return imageUrl;
  }

  // =========================================
  // SAVE PROFILE
  // =========================================
Future<void> saveProfile() async {

  try {

    setState(() {
      loading = true;
    });

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not logged in"),
        ),
      );

      return;
    }

    String imageUrl = "";

    // ==================================
    // IMAGE UPLOAD
    // ==================================

    if (image != null) {

      imageUrl =
          await uploadImageToSupabase(
            image!,
          );
    }

    // ==================================
    // SAVE SUPABASE DATABASE
    // ==================================

    await Supabase.instance.client
        .from("business_profiles")
        .upsert({

      "id": user.id,

      "business_name":
      businessNameController.text.trim(),

      "owner_name":
      ownerNameController.text.trim(),

      "category":
      selectedCategory,

      "google_review_link":
      googleLinkController.text,

      "logo":
      imageUrl,

      "email":
      user.email,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile Saved"),
      ),
    );

    // ==================================
    // OPEN HOME
    // ==================================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const HomeScreen(),
      ),
    );

  } catch (e) {

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  if (mounted) {
    setState(() {
      loading = false;
    });
  }
}

  // =========================================
  // PICK IMAGE
  // =========================================

  Future<void> pickImage() async {

    final picked =
        await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {

      setState(() {
        image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF4F5F7),

      // ======================================
      // APP BAR
      // ======================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        centerTitle: true,

        title: Row(
          mainAxisSize: MainAxisSize.min,

          children: [

            const Icon(
              Icons.business,
              color: Color(0xff003D9B),
              size: 32,
            ),

            const SizedBox(width: 10),

            Text(
              "ReviewMate",

              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                color: const Color(0xff003D9B),
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),

      // ======================================
      // BODY
      // ======================================

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(22),

        child: Center(

          child: Container(

            constraints: const BoxConstraints(
              maxWidth: 700,
            ),

            child: Column(
              children: [

                // =====================================
                // TITLE
                // =====================================

                Text(
                  "Setup Business Profile",

                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Complete your profile to start collecting reviews.",

                  textAlign: TextAlign.center,

                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                // =====================================
                // FORM CARD
                // =====================================

                Container(

                  padding: const EdgeInsets.all(28),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                    BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color:
                        Colors.black.withOpacity(0.04),
                      )
                    ],
                  ),

                  child: Column(
                    children: [

                      // ===============================
                      // LOGO SECTION
                      // ===============================

                      Align(
                        alignment:
                        Alignment.centerLeft,

                        child: Text(
                          "Business Logo",

                          style: GoogleFonts.inter(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(

                        onTap: pickImage,

                        child: Column(
                          children: [

                            Container(
                              width: 120,
                              height: 120,

                              decoration: BoxDecoration(
                                color:
                                const Color(
                                  0xffF5F7FF,
                                ),

                                shape: BoxShape.circle,

                                border: Border.all(
                                  color:
                                  Colors.grey
                                      .shade300,
                                  width: 2,
                                ),
                              ),

                              child: image == null
                                  ? const Icon(
                                Icons
                                    .photo_camera,
                                size: 40,
                                color: Colors
                                    .grey,
                              )
                                  : ClipOval(
                                child: Image.file(
                                  image!,
                                  fit: BoxFit
                                      .cover,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              "Tap to upload logo",

                              style:
                              GoogleFonts.inter(
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      // =================================
                      // BUSINESS NAME
                      // =================================

                      buildField(
                        title: "Business Name",
                        hint:
                        "e.g. Acme Corporation",
                        controller:
                        businessNameController,
                        icon: Icons.business,
                      ),

                      const SizedBox(height: 24),

                      // =================================
                      // OWNER NAME
                      // =================================

                      buildField(
                        title: "Owner Name",
                        hint: "John Doe",
                        controller:
                        ownerNameController,
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 24),

                      // =================================
                      // CATEGORY
                      // =================================

                      Align(
                        alignment:
                        Alignment.centerLeft,

                        child: Text(
                          "Business Category/Type",

                          style: GoogleFonts.inter(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField(

                        value:
                        selectedCategory.isEmpty
                            ? null
                            : selectedCategory,

                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                          const Color(
                            0xffF8F9FC,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(18),

                            borderSide: BorderSide(
                              color: Colors
                                  .grey.shade300,
                            ),
                          ),
                        ),

                        hint: Text(
                          "Select Category",
                          style: GoogleFonts.inter(),
                        ),

                        items: categories.map((e) {

                          return DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),

                        onChanged: (value) {

                          setState(() {
                            selectedCategory =
                            value.toString();
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // =================================
                      // GOOGLE REVIEW LINK
                      // =================================

                      buildField(
                        title: "Google Review Link",

                        hint:
                        "https://g.page/r/your-id/review",

                        controller:
                        googleLinkController,

                        icon: Icons.link,
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          const Icon(
                            Icons.help_outline,
                            color: Colors.grey,
                            size: 18,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              "How do I find my Google review link?",

                              style:
                              GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 35),

                      // =================================
                      // SAVE BUTTON
                      // =================================

                     SizedBox(
  width: double.infinity,

  child: ElevatedButton(

    style: ElevatedButton.styleFrom(

      backgroundColor:
      const Color(0xff003D9B),

      padding:
      const EdgeInsets.symmetric(
        vertical: 18,
      ),

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
    ),

    onPressed: saveProfile,

    child: loading
        ? const CircularProgressIndicator(
            color: Colors.white,
          )
        : Text(
            "Save Profile",

            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
  ),
),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CUSTOM FIELD
  // ==========================================

  Widget buildField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,

          decoration: InputDecoration(

            hintText: hint,

            prefixIcon: Icon(icon),

            filled: true,
            fillColor: const Color(0xffF8F9FC),

            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(18),

              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),

            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(18),

              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),

            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(18),

              borderSide: const BorderSide(
                color: Color(0xff003D9B),
                width: 2,
              ),
            ),
          ),
        )
      ],
    );
  }
}