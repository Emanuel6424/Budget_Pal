import 'package:flutter/material.dart';

class Helpers {
// **Helper function: Convert icon name string to `IconData`**
  IconData _stringToIconData(String iconName) {
    switch (iconName) {
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'attach_money':
        return Icons.attach_money;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'group':
        return Icons.group;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'calculate':
        return Icons.calculate;
      case 'menu_book':
        return Icons.menu_book;
      case 'science':
        return Icons.science;
      case 'history_edu':
        return Icons.history_edu;
      case 'music_note':
        return Icons.music_note;
      case 'brush':
        return Icons.brush;
      case 'code':
        return Icons.code;
      case 'book':
        return Icons.book;
      case 'create':
        return Icons.create;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'flight':
        return Icons.flight;
      case 'person':
        return Icons.person;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'palette':
        return Icons.palette;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'smartphone':
        return Icons.smartphone;
      case 'arrow_right':
        return Icons.arrow_right;
      default:
        return Icons.help_outline; // Fallback icon if not found
    }
  }

  Map<String, IconData> convertIconPreferences(
      Map<String, String> iconPreferences) {
    return iconPreferences.map((key, value) {
      return MapEntry(key, _stringToIconData(value));
    });
  }
}
