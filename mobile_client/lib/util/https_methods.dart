import 'dart:convert';

import 'package:budget_pal/models/budget_status.dart';
import 'package:budget_pal/models/transaction.dart';
import 'package:budget_pal/models/user.dart';
import 'package:http/http.dart' as http;
import 'endpoints.dart';

class HttpsMethods {
  final headers = {'Content-Type': 'application/json'};

  Future<User?> signUpUser(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    var url = Uri.parse(Endpoints.createUserUrl());

    final body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print("User created successfully!");
        var userJson = jsonDecode(response.body);
        return User.fromJson(userJson);
        // TODO: Parse response and store in Provider
      } else {
        print('Failed to create user: ${response.body}');
        return null; // Failure
      }
    } catch (e) {
      print("Error: $e");
      return null; // Failure
    }
  }

  Future<User?> loginUser(String email, String password) async {
    var url = Uri.parse(Endpoints.loginUserUrl());

    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Login successful!"); // Fixed message
        var userJson = jsonDecode(response.body);
        return User.fromJson(userJson);

        // TODO: Parse response, create Person object, store in Provider, navigate
      } else if (response.statusCode == 401) {
        throw Exception("User not found or invalid credentials");
        // TODO: Show error to user
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    var url = Uri.parse(Endpoints.getUserByEmailUrl(email));

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var userJson = jsonDecode(response.body);
        return User.fromJson(userJson);
      } else {
        print('Failed to fetch user: ${response.body}');
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<void> createAccount(
    String name,
    String type,
    String accountNumber,
    double balance,
    int userId,
  ) async {
    var url = Uri.parse(Endpoints.createAccountUrl());

    final body = jsonEncode({
      'name': name,
      'type': type,
      'accountNumber': accountNumber,
      'balance': balance,
      'userId': userId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print("User created successfully!");
      } else {
        print('Failed to create user: ${response.body}');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<List<Transaction>> getTransactions(int accountId) async {
    // Type it properly
    try {
      var url = Uri.parse(Endpoints.getTransactionsUrl(accountId));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Should be 200 for GET, not 201
        final List<dynamic> fetchedTransactions = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        // Map to Transaction objects
        List<Transaction> transactions = fetchedTransactions
            .map((json) => Transaction.fromJson(json))
            .toList();

        // Sort by date (newest first is more common for transactions)
        transactions.sort((a, b) => b.date.compareTo(a.date));

        return transactions;
      } else {
        print("Failed to fetch transactions: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      throw Exception("Error fetching transactions: $e");
    }
  }

  // In util/https_methods.dart
  Future<BudgetStatus?> getBudgetStatus(int budgetId) async {
    try {
      var url = Uri.parse(Endpoints.getBudgetStatusUrl(budgetId));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return BudgetStatus.fromJson(data);
      } else {
        throw Exception(
          "Failed to fetch budget status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error fetching budget status: $e");
      return null;
    }
  }
}
