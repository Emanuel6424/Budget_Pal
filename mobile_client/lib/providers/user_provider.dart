import 'package:flutter/material.dart';
import "../models/person.dart";

class UserProvider extends ChangeNotifier {
  // Private varible to store the account data
  // The underscore make it private to this class
  Person? _account;

  // Public getting to access account data
  // Other widget will use this to read the current account
  Person? get account => _account;

  // Method is used to set the inital account data (when the user logs in)
  void setAccount(Person account) {
    _account = account;
    // notifyListeners() tells all the widgets listeing to this provider
    // that the data has changed and they should rebuild
    notifyListeners();
  }

  // Method to update just the preferences without replace the whole account
  void updtaePreferences(
    Map<String, String>? iconPreferences,
    Map<String, String>? colorPreferences,
  ) {
    if (_account != null) {
      // Create a new Person object with updated preferences
      // We create a new obkect instead of modifying the existing one
      // Because it follows fullters immutability principle LOOK MORE INTO THIS
      _account = Person(
        id: _account!.id,
        firstname: _account!.firstname,
        lastname: _account!.lastname,
        email: _account!.email,
        photoUrl: _account!.photoUrl,
        // Use new preferences if provided, otherswise keep existing ones
        iconPreferences: iconPreferences ?? _account!.iconPreferences,
        colorPreferences: colorPreferences ?? _account!.colorPreferences,
      );
      // Notify all listening widgets that data has changed
      notifyListeners();
    }
  }

  // Method to clear account data (like when user logs out)
  void logout() {
    _account = null;
    notifyListeners();
  }

  // Helper method to check if user is loogged in
  bool get isLoggedIn => _account != null;

  // Helper getters for commonly used account properties
  String get fullName =>
      _account != null ? "${_account!.firstname} ${account!.lastname}" : '';

  int? get accountId => _account?.id;

  Map<String, String>? get iconPreferences => _account?.iconPreferences ?? {};
  Map<String, String>? get colorPreferences => _account?.colorPreferences ?? {};
}
