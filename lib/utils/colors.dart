import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4F7CFF);

  static const Color secondary = Color(0xFF7C5CFF);

  static const Color background = Color(0xFFF5F7FB);

  static const Color card = Colors.white;

  static const Color success = Color(0xFF2ECC71);

  static const Color warning = Color(0xFFFF9800);

  static const Color danger = Color(0xFFE74C3C);

  static const Color textDark = Color(0xFF222222);

  static const Color textGrey = Color(0xFF777777);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
