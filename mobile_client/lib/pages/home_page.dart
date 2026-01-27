// import 'package:aspires/Models/Person.dart';
// import 'package:aspires/pages/Tasks/task_list_page.dart';
import 'package:flutter/material.dart';
import '../widgets/account_widget.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AccountWidget(
                accountNumber: "12345678",
                name: "Main Checkings",
                type: "Checking",
                balance: 14000.00,
              ),
              AccountWidget(
                accountNumber: "12345678",
                name: "Main Checkings",
                type: "Checking",
                balance: 14000.00,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
