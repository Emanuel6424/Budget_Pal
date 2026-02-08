import 'package:budget_pal/models/account.dart';
import 'package:flutter/material.dart';
import "../models/user.dart";

class UserProvider extends ChangeNotifier {
  // Private varible to store the user data
  // The underscore make it private to this class
  User? _user;

  // Public getting to access user data
  // Other widget will use this to read the current user
  User? get user => _user;

  // Method is used to set the inital user data (when the user logs in)
  void setUser(User user) {
    _user = user;
    // notifyListeners() tells all the widgets listeing to this provider
    // that the data has changed and they should rebuild
    notifyListeners();
  }

  // Method to clear user data (like when user logs out)
  void logout() {
    _user = null;
    notifyListeners();
  }

  // Helper method to check if user is loogged in
  bool get isLoggedIn => _user != null;

  // Helper getters for commonly used user properties
  String get fullName =>
      _user != null ? "${_user!.firstname} ${user!.lastname}" : '';

  int? get userId => _user?.id;

  void updateAccounts(List<Account> accounts) {
    if (_user != null) {
      _user!.accounts = accounts;
      notifyListeners();
    }
  }
}
