import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTypography {
  static TextStyle get heading28 => GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.7);
  static TextStyle get heading22 => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.4);
  static TextStyle get heading18 => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2);
  static TextStyle get body15 => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.15);
  static TextStyle get body14 => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: -0.1);
  static TextStyle get body13 => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: -0.065);
  static TextStyle get caption12 => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0);
  static TextStyle get mono11 => GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 0.88);
  static TextStyle get mono12 => GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.5);
  static TextStyle get mono22 => GoogleFonts.jetBrainsMono(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0);
  static TextStyle get mono64 => GoogleFonts.jetBrainsMono(fontSize: 64, fontWeight: FontWeight.w300, letterSpacing: -2.56);
}
