// import 'package:aspires/Models/Person.dart';
// import 'package:aspires/pages/Tasks/task_list_page.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';
import 'package:provider/provider.dart';
import '../models/person.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../util/endpoints.dart';

// ignore: must_be_immutable
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Title(
              title: "BudgetPal",
              color: const Color(0xFF5D4037),
              child: Text("BudgetPal"),
            ),
            const SizedBox(height: 20),
            Container(
              width: 350,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF5D4037), width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
