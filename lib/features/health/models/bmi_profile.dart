import 'package:flutter/material.dart';

class BmiProfile {
  final String? gender;
  final int age;
  final double height_cm;
  final double weight_kg;
  final bool is_calculated;

  const BmiProfile({
    this.gender,
    this.age = 25,
    this.height_cm = 170,
    this.weight_kg = 70,
    this.is_calculated = false,
  });

  static const fallback_bmi = 22.4;

  double get bmi {
    final h = height_cm / 100;
    return weight_kg / (h * h);
  }

  double get display_bmi => is_calculated ? bmi : fallback_bmi;
}

String bmiLabelFor(double bmi) {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
}

Color bmiColorFor(double bmi) {
  if (bmi < 18.5) return const Color(0xFF0A84FF);
  if (bmi < 25) return const Color(0xFF1DB954);
  if (bmi < 30) return const Color(0xFFFF9500);
  return const Color(0xFFFF375F);
}

double bmiProgressFor(double bmi) {
  return ((bmi - 10) / 30).clamp(0.0, 1.0);
}
