import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'endpoints.dart';

class HttpsMethods {
  Future<bool> signUpUser(
    String firstName,
    String lastName,
    String email,
    String password,
    BuildContext context, // Add this - need for Provider & navigation
  ) async {
    var url = Uri.parse(Endpoints.createUserUrl());

    final body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });

    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print("User created successfully!");
        // TODO: Parse response and store in Provider
        return true; // Success
      } else {
        print('Failed to create user: ${response.body}');
        return false; // Failure
      }
    } catch (e) {
      print("Error: $e");
      return false; // Failure
    }
  }

  Future<bool> loginUser(
    String email,
    String password,
    BuildContext context, // Add this
  ) async {
    var url = Uri.parse(Endpoints.loginUserUrl());

    final body = jsonEncode({'email': email, 'password': password});

    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Login successful!"); // Fixed message
        return true;

        // TODO: Parse response, create Person object, store in Provider, navigate
      } else if (response.statusCode == 401) {
        throw Exception("User not found or invalid credentials");
        return false;
        // TODO: Show error to user
      } else {
        throw Exception('Failed to login: ${response.body}');
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
