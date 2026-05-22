import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {

  static heading({
    double size = 28,
    FontWeight weight = FontWeight.bold,
    Color color = Colors.black,
  }) {

    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static body({
    double size = 16,
    Color color = Colors.black54,
  }) {

    return GoogleFonts.inter(
      fontSize: size,
      color: color,
    );
  }
}