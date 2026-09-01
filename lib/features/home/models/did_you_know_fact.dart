import 'package:flutter/material.dart';

class DidYouKnowFact {
  final String id;
  final String icon;
  final String fact;
  final Color accent;
  final List<Color> gradient_colors;

  const DidYouKnowFact({
    required this.id,
    required this.icon,
    required this.fact,
    required this.accent,
    required this.gradient_colors,
  });

  factory DidYouKnowFact.fromJson(Map<String, dynamic> json) {
    return DidYouKnowFact(
      id: json['id']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '💡',
      fact: json['fact']?.toString() ?? '',
      accent: colorFromHex(json['accent_hex']?.toString() ?? '#1DB954'),
      gradient_colors: [
        colorFromHex(json['gradient_start_hex']?.toString() ?? '#1A3A1A'),
        colorFromHex(json['gradient_end_hex']?.toString() ?? '#0D2010'),
      ],
    );
  }

  Map<String, dynamic> toBannerMap() {
    return {
      'icon': icon,
      'fact': fact,
      'colors': gradient_colors,
      'accent': accent,
    };
  }

  static Color colorFromHex(String hex) {
    var value = hex.replaceFirst('#', '').trim();
    if (value.length == 6) {
      value = 'FF$value';
    }
    return Color(int.parse(value, radix: 16));
  }
}
