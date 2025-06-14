import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class FavoriteCalcItem extends Equatable {
  final String title;
  final String routeName;
  final IconData icon;

  const FavoriteCalcItem({
    required this.title,
    required this.routeName,
    required this.icon,
  });

  @override
  List<Object> get props => [routeName];

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {'title': title, 'routeName': routeName, 'icon': icon.codePoint};
  }

  // For JSON deserialization
  factory FavoriteCalcItem.fromJson(Map<String, dynamic> json) {
    return FavoriteCalcItem(
      title: json['title'] as String,
      routeName: json['routeName'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
    );
  }
}
