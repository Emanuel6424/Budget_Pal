import 'package:flutter/material.dart';
import '../widgets/account_widget.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Budget Pal",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Accounts",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Total Balance: ", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Add Account"),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                AccountWidget(
                  accountNumber: "12345678",
                  name: "Main Checkings",
                  type: "Checking",
                  balance: 14000.00,
                ),
                AccountWidget(
                  accountNumber: "12345678",
                  name: "Main Savings",
                  type: "Savings",
                  balance: 14000.00,
                ),
                AccountWidget(
                  accountNumber: "12345678",
                  name: "Main Retirement",
                  type: "Retirement",
                  balance: 14000.00,
                ),
                AccountWidget(
                  accountNumber: "12345678",
                  name: "Main Credit Card",
                  type: "Credit Card",
                  balance: 14000.00,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
