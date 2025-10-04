import 'package:flutter/material.dart';

class AppColors {
  // 🎨 Base Theme Colors
  // 🧱 Backgrounds
   // Soft pastel blue
  static const Color mainBg = Color(0xFF0D0D0D);            // Dark Main BG
  static const Color cardBg = Color.fromARGB(255, 0, 10, 12);            // Dark Card BG
  static const Color commentBg =Color.fromARGB(255, 6, 31, 43);         // Dark Comment BG

  // 📝 Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color nameText = Color(0xFFFFFFFF);   
    static const Color titleText = Color(0xFFFFFFFF);       // Post: Name
  static const Color locationTimeText = Color(0xFFAAAAAA);  // Post: Location & time
  static const Color postText = Color(0xFFE0E0E0);          // Post: Text
  static const Color showMoreText = Color(0xFF00E0FF);      // Post: "Show More"
  static const Color commentorName = Color(0xFFFFFFFF);     // Comment: Name
  static const Color commentText = Color(0xFFCCCCCC);       // Comment: Text
  static const Color commentPlaceholder = Color(0xFF777777); // Comment: Placeholder
static const Color centerleft = Color(0xFF01121c);
  static const Color centerright = Color(0xFF001B26);
  static const Color appbar = Colors.black;
  // ✅ Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // 🎯 Icons & Buttons
  static const Color iconLike = Color(0xFF00E0FF);         // Like icon
  static const Color iconReply = Color(0xFF00E0FF);        // Reply icon (same as Like)
  static const Color iconShare = Color(0xFFB0B0B0);        // Share icon (subtle gray)
  static const Color buttonBg =  Color(0xFF00D1D8); // FAB background (aqua)
  static const Color icons =  Color(0xFF00D1D8); // FAB background (aqua)

  // Optionally you can add a glow or shadow color if needed later
}