// import 'package:aspires/Models/Person.dart';
// import 'package:aspires/pages/Tasks/task_list_page.dart';
import 'package:flutter/material.dart';

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
            ElevatedButton(
              onPressed: () {
                print("Main Page YAY!");
              },
              child: const Text("Go to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
