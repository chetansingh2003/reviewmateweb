import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {

  bool darkMode = false;
  Map<String, dynamic>? profileData;
  bool loadingProfile = true;
  bool saving = false;
  File? logoImage;
  final reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  Future<void> getProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          loadingProfile = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from("business_profiles")
          .select()
          .eq("id", user.id)
          .maybeSingle();

      if (response != null) {
        profileData = response;
        reviewController.text = response["google_review_link"] ?? "";
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) {
        setState(() {
          loadingProfile = false;
        });
      }
    }
  }

  Future<void> saveSettings() async {
    try {
      setState(() {
        saving = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "User not logged in";

      String logoUrl = profileData?["logo"] ?? "";

      if (logoImage != null) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        await Supabase.instance.client.storage
            .from('business-logos')
            .upload(
              fileName,
              logoImage!,
            );
        logoUrl = Supabase.instance.client.storage
            .from('business-logos')
            .getPublicUrl(fileName);
      }

      await Supabase.instance.client
          .from("business_profiles")
          .upsert({
        "id": user.id,
        "business_name": profileData?["business_name"] ?? "",
        "google_review_link": reviewController.text.trim(),
        "logo": logoUrl,
      });

      await getProfileData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("QR Settings Saved Successfully"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving settings: $e"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  // ==========================================
  // PICK LOGO
  // ==========================================

  Future<void> pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        logoImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor: darkMode
          ? const Color(0xff0F172A)
          : const Color(0xffF4F7FC),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            top: 22,
            bottom: 120,
          ),

child: Column(
  children: [

    // ===================================
    // QR MAIN CARD
    // ===================================

    Container(

      width: double.infinity,

      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(

        gradient: const LinearGradient(
          colors: [
            Color(0xff0052CC),
            Color(0xff3B82F6),
          ],
        ),

        borderRadius:
        BorderRadius.circular(32),

        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            color:
            Colors.blue.withOpacity(0.25),
          )
        ],
      ),

      child: Column(
        children: [

          // ===================================
          // REAL QR CODE
          // ===================================

          Container(

            padding:
            const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
              BorderRadius.circular(24),
            ),

            child: Stack(

              alignment: Alignment.center,

              children: [

                // =============================
                // QR IMAGE
                // =============================

                QrImageView(

                  data:
                  "http://192.168.31.137:5173/review?id=${profileData?["id"]}",

                  version: QrVersions.auto,

                  size: 220,

                  backgroundColor:
                  Colors.white,
                ),

                // =============================
                // CENTER LOGO
                // =============================

                if (
                logoImage != null ||

                    (
                    profileData?["logo"] != null &&
                        profileData!["logo"]
                            .toString()
                            .isNotEmpty
                    )
                )

                  Container(

                    width: 52,
                    height: 52,

                    decoration:
                    BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(14),
                    ),

                    child: ClipRRect(

                      borderRadius:
                      BorderRadius.circular(12),

                      child:

                      logoImage != null

                          ? Image.file(
                              logoImage!,
                              fit: BoxFit.cover,
                            )

                          : Image.network(
                              profileData!["logo"],
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===================================
          // TITLE
          // ===================================

          Text(
            "Review QR",

            style: GoogleFonts.inter(
              fontSize: 34,
              fontWeight:
              FontWeight.w800,

              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          // ===================================
          // SUBTITLE
          // ===================================

          Text(
            "Collect customer reviews easily",

            textAlign: TextAlign.center,

            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 30),

          // ===================================
          // BUTTONS
          // ===================================

          Row(
            children: [

              Expanded(
                child: qrButton(
                  Icons.download,
                  "Download",
                  Colors.white,
                  const Color(
                    0xff0052CC,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: qrButton(
                  Icons.share,
                  "Share",
                  Colors.white
                      .withOpacity(0.15),
                  Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    ),

    const SizedBox(height: 24),
              // ===================================
              // CUSTOMIZATION SECTION
              // ===================================

              sectionCard(
                title: "Review QR Settings",
                icon: Icons.settings,

                child: Column(
                  children: [

                    // ===================================
                    // REVIEW LINK FIELD
                    // ===================================

                    TextField(

                      controller:
                      reviewController,

                      onChanged: (v) {

                        setState(() {});
                      },

                      style: GoogleFonts.inter(
                        color: darkMode
                            ? Colors.white
                            : Colors.black,
                      ),

                      decoration:
                      InputDecoration(

                        labelText:
                        "Google Review Link",

                        filled: true,

                        fillColor: darkMode
                            ? const Color(
                          0xff1E293B,
                        )
                            : const Color(
                          0xffF8FAFC,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),

                          borderSide:
                          BorderSide.none,
                        ),

                        suffixIcon:
                        IconButton(

                          onPressed: () {

                            Clipboard.setData(
                              ClipboardData(
                                text:
                                reviewController
                                    .text,
                              ),
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              const SnackBar(
                                content: Text(
                                  "Review Link Copied",
                                ),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.copy,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===================================
                    // UPLOAD LOGO
                    // ===================================

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(
                            0xff0052CC,
                          ),

                          padding:
                          const EdgeInsets
                              .symmetric(
                            vertical: 16,
                          ),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),
                          ),
                        ),

                        onPressed: pickLogo,

                        icon: const Icon(
                          Icons.upload,
                          color: Colors.white,
                        ),

                        label: Text(
                          "Upload Business Logo",

                          style:
                          GoogleFonts.inter(
                            color:
                            Colors.white,

                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===================================
                    // SAVE BUTTON
                    // ===================================

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkMode
                              ? const Color(0xff1E293B)
                              : const Color(0xffEEF2FF),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: saving ? null : saveSettings,
                        icon: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.save,
                                color: darkMode ? Colors.white : Colors.black,
                              ),
                        label: Text(
                          saving ? "Saving Settings..." : "Save QR Settings",
                          style: GoogleFonts.inter(
                            color: darkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===================================
                    // LOGO PREVIEW
                    // ===================================

                    if (logoImage != null || (profileData?["logo"] != null && profileData!["logo"].toString().isNotEmpty))
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          image: DecorationImage(
                            image: logoImage != null
                                ? FileImage(logoImage!) as ImageProvider
                                : NetworkImage(profileData!["logo"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===================================
              // QUICK ACTIONS
              // ===================================

              sectionCard(
                title: "Quick Actions",
                icon: Icons.flash_on,

                child: Column(
                  children: [

                    actionTile(
                      Icons.copy,
                      "Copy Review Link",
                    ),

                    const Divider(),

                    actionTile(
                      Icons.download,
                      "Download QR Poster",
                    ),

                    const Divider(),

                    actionTile(
                      Icons.share,
                      "Share QR With Customers",
                    ),

                    const Divider(),

                    actionTile(
                      Icons.print,
                      "Print QR Code",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // QR BUTTON
  // ==========================================

  Widget qrButton(
      IconData icon,
      String text,
      Color bg,
      Color fg,
      ) {

    return ElevatedButton.icon(

      style: ElevatedButton.styleFrom(
        backgroundColor: bg,

        elevation: 0,

        padding:
        const EdgeInsets.symmetric(
          vertical: 16,
        ),

        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(18),
        ),
      ),

      onPressed: () {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(
              "$text clicked",
            ),
          ),
        );
      },

      icon: Icon(icon, color: fg),

      label: Text(
        text,

        style: GoogleFonts.inter(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ==========================================
  // SECTION CARD
  // ==========================================

  Widget sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        color: darkMode
            ? const Color(0xff111827)
            : Colors.white,

        borderRadius:
        BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color:
            Colors.black.withOpacity(
              0.04,
            ),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Icon(
                icon,
                color: const Color(
                  0xff0052CC,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                title,

                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w700,

                  color: darkMode
                      ? Colors.white
                      : Colors.black,
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

  // ==========================================
  // ACTION TILE
  // ==========================================

  Widget actionTile(
      IconData icon,
      String title,
      ) {

    return ListTile(

      contentPadding: EdgeInsets.zero,

      leading: Container(
        width: 48,
        height: 48,

        decoration: BoxDecoration(
          color: const Color(
            0xff0052CC,
          ).withOpacity(0.12),

          borderRadius:
          BorderRadius.circular(14),
        ),

        child: Icon(
          icon,
          color: const Color(
            0xff0052CC,
          ),
        ),
      ),

      title: Text(
        title,

        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,

          color: darkMode
              ? Colors.white
              : Colors.black,
        ),
      ),

      trailing: const Icon(
        Icons.chevron_right,
      ),

      onTap: () {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(
              "$title clicked",
            ),
          ),
        );
      },
    );
  }
}