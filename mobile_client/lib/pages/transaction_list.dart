import 'package:budget_pal/models/transaction.dart';
import 'package:budget_pal/util/https_methods.dart';
import 'package:budget_pal/widgets/transactions/account_header_widget.dart';
import 'package:budget_pal/widgets/transactions/transaction_widget.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import "../../providers/user_provider.dart";

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPage();
}

class _TransactionListPage extends State<TransactionListPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        if (user == null) {
          return Scaffold(body: Center(child: Text('No user found')));
        }

        return Scaffold(
          appBar: AppBar(title: Text("Transactions")),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transactions",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Purchase History For This Month",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print("hello");
                        },
                        child: Text("+ Transaction"),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Transactions section with card container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),

                          // Check if transactions exist and display them
                          if (user.recentTransactions.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  'No transactions found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          else
                            ...user.recentTransactions.map((transaction) {
                              return TransactionWidget(
                                date: transaction.date,
                                description: transaction.description,
                                categoryId: transaction.categoryId,
                                amount: transaction.amount,
                                type: transaction.type,
                                merchant: transaction.merchant,
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// quick fix, this is to be replaced as soon as I implement categories back end
class CategoryHelper {
  static const Map<int, String> categoryNames = {
    1: 'Groceries',
    2: 'Dining',
    3: 'Transportation',
    4: 'Entertainment',
    5: 'Utilities',
    6: 'Healthcare',
    7: 'Shopping',
    8: 'Housing',
    9: 'Income',
    10: 'Other',
  };

  static String getCategoryName(int id) {
    return categoryNames[id] ?? 'Unknown';
  }
}
