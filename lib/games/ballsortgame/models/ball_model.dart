import 'package:flutter/material.dart';

class BallModel {
  final int colorIndex;

  const BallModel({required this.colorIndex});

  BallModel copyWith({int? colorIndex}) {
    return BallModel(colorIndex: colorIndex ?? this.colorIndex);
  }

  Map<String, dynamic> toJson() => {'colorIndex': colorIndex};

  factory BallModel.fromJson(Map<String, dynamic> json) {
    return BallModel(colorIndex: json['colorIndex'] as int);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BallModel &&
          runtimeType == other.runtimeType &&
          colorIndex == other.colorIndex;

  @override
  int get hashCode => colorIndex.hashCode;
}

// All available ball colors
const List<Color> kBallColors = [
  Color(0xFFE74C3C), // Red
  Color(0xFF3498DB), // Blue
  Color(0xFF2ECC71), // Green
  Color(0xFFF39C12), // Orange
  Color(0xFF9B59B6), // Purple
  Color(0xFF1ABC9C), // Teal
  Color(0xFFE91E63), // Pink
  Color(0xFF00BCD4), // Cyan
  Color(0xFF8BC34A), // Light Green
  Color(0xFFFF5722), // Deep Orange
  Color(0xFF607D8B), // Blue Grey
  Color(0xFFFFEB3B), // Yellow
];
