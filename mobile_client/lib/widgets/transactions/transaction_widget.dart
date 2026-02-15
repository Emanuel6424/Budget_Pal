import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionWidget extends StatelessWidget {
  final DateTime date;
  final String description;
  final String category;
  final double amount;
  final String type;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  TransactionWidget({
    super.key,
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Icon
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: type == "DEBIT"
                    ? const Color.fromARGB(80, 244, 67, 54)
                    : const Color.fromARGB(86, 76, 175, 79),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                type == "DEBIT" ? Icons.trending_down : Icons.trending_up,
                size: 20,
                color: type == "DEBIT" ? Colors.red : Colors.green,
              ),
            ),

            SizedBox(width: 16), // Add spacing here
            // Middle - Description and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat.MMMd().format(date),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Right side - Amount and category
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  type == "DEBIT"
                      ? "-${currencyFormat.format(amount)}"
                      : "+${currencyFormat.format(amount)}",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: type == "DEBIT" ? Colors.red : Colors.green,
                  ),
                ),
                SizedBox(height: 4),
                Text(category, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
