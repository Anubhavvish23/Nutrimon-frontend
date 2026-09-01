import 'package:flutter/material.dart';
import '../../plans/models/recipe.dart';

class SymptomCatalogItem {
  final String id;
  final String slug;
  final String name;
  final String emoji;
  final String severity;
  final Color color;

  const SymptomCatalogItem({
    required this.id,
    required this.slug,
    required this.name,
    required this.emoji,
    required this.severity,
    required this.color,
  });

  factory SymptomCatalogItem.fromJson(Map<String, dynamic> json) {
    return SymptomCatalogItem(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '⚡',
      severity: json['severity']?.toString() ?? 'MILD',
      color: Recipe.colorFromHex(json['color_hex']?.toString() ?? '#FF9500'),
    );
  }

  Map<String, dynamic> toCardMap() {
    return {
      'slug': slug,
      'emoji': emoji,
      'name': name,
      'severity': severity,
      'color': color,
    };
  }
}
