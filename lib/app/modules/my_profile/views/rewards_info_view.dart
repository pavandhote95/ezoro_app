import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_color.dart';

class RewardsInfoView extends StatelessWidget {
  const RewardsInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        elevation: 0,
        title: Text(
          "Rewards & Verification",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
body: SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      // ====== FIRST CONTAINER ======
      _infoCard(
        sections: [
          _Section(
            icon: "⭐",
            title: "How Points Work",
            items: [
              "Post a question or travel tip → +15 points",
              "Reply to a question → no points",
              "If the person who asked the question likes your reply → +10 points",
            ],
          ),
          _Section(
            icon: "🏅",
            title: "Get Verified",
            items: [
              "Collect 1000 points",
              "Apply for a Verified Account (valid for 1 year)",
            ],
          ),
        ],
      ),
      const SizedBox(height: 16),
      // ====== SECOND CONTAINER ======
      _infoCard(
        sections: [
          _Section(
            icon: "🎖",
            title: "Benefits of a Verified Account",
            items: [
              "Blue Tick Badge – stand out as a trusted traveler",
              "Priority Replies – your answers show higher",
              "Profile Boost – highlighted profile for more followers",
              "Exclusive Perks – early access to features & events",
              "Credibility – answers trusted more (great for influencers)",
              "Monetization Gateway (future) – earn by creating itineraries",
            ],
            numbered: true,
          ),
        ],
      ),
      const SizedBox(height: 16),
      // ====== FOOTER MESSAGE ======
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        ),
        child: Text(
          "👉 Ask more, help more, get liked, and become Verified!",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
),

  
    );
  }

  Widget _infoCard({
    required List<_Section> sections,
    String? footer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.centerright, AppColors.centerleft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sections.map((section) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(section.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        section.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...section.items.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final text = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.numbered ? "$index) " : "• ",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              text,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              )),
          if (footer != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Text(
                footer,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Section {
  final String icon;
  final String title;
  final List<String> items;
  final bool numbered;

  _Section({
    required this.icon,
    required this.title,
    required this.items,
    this.numbered = false,
  });
}
