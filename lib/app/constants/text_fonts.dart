import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KTextStyle {
  static TextStyle _build({
    required TextStyle Function({TextStyle? textStyle}) font,
    double fs = 14,
    Color c = Colors.black,
    FontWeight fw = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
    double? wordSpacing,
    Color? decorationColor,
  }) {
    return font().copyWith(
      fontSize: fs,
      color: c,
      fontWeight: fw,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing,
      height: height,
      wordSpacing: wordSpacing,
      decorationColor: decorationColor,
    );
  }

  static TextStyle montSerrat({
    double fs = 14,
    Color c = Colors.black,
    FontWeight fw = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
    double? wordSpacing,
    Color? decorationColor,
  }) =>
      _build(
        font: GoogleFonts.montserrat,
        fs: fs,
        c: c,
        fw: fw,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
        wordSpacing: wordSpacing,
        decorationColor: decorationColor,
      );

// Add more fonts if needed (Outfit, Inter, Sen, etc.)
}
