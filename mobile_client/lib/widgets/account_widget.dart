import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountWidget extends StatelessWidget {
  final String name;
  final String type;
  final String accountNumber;
  final double balance;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  AccountWidget({
    super.key,
    required this.name,
    required this.type,
    required this.accountNumber,
    required this.balance,
  });

  Map<String, IconData> accountTypeIcons = {
    "Checking": Icons.account_balance_wallet_outlined,
    "Savings": Icons.savings_outlined,
    "Retirement": Icons.beach_access_outlined,
    "Credit Card": Icons.credit_card_outlined,
  };

  Map<String, Color> accountTypeHighlight = {
    "Checking": const Color.fromARGB(82, 255, 255, 0),
    "Savings": const Color.fromARGB(80, 105, 240, 175),
    "Retirement": const Color.fromARGB(80, 158, 158, 158),
    "Credit Card": const Color.fromARGB(76, 255, 172, 64),
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onDoubleTap: () {
          print("You have tapped your $type Account");
        },
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon(accountTypeIcons[type], size: 30, color: Colors.black),
                  Container(
                    padding: EdgeInsets.all(12), // Space around icon
                    decoration: BoxDecoration(
                      color: accountTypeHighlight[type], // Light background
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Rounded corners
                    ),
                    child: Icon(
                      accountTypeIcons[type],
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                  Text(accountNumber),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(type + " Account"),
                  ),
                  Text(
                    currencyFormat.format(balance),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
