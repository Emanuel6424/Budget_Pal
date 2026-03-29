import 'package:budget_pal/models/transaction.dart';
import 'package:budget_pal/util/https_methods.dart';
import 'package:budget_pal/widgets/transactions/add_transaction_dialog.dart'; // Add this
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
                            "Transactions This Month",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Show account selection dialog first if user has multiple accounts
                          if (user.accounts.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please create an account first'),
                              ),
                            );
                            return;
                          }

                          // If only one account, use it. Otherwise, let user choose
                          int accountId = user.accounts.length == 1
                              ? user.accounts.first.id
                              : user
                                    .accounts
                                    .first
                                    .id; // For now, default to first account

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddTransactionDialog(
                                accounts: user
                                    .accounts, // Pass accounts for selection
                                onAdd:
                                    (
                                      accountId,
                                      date,
                                      description,
                                      merchant,
                                      amount,
                                      type,
                                      categoryId,
                                    ) async {
                                      try {
                                        // Call API to create transaction
                                        await HttpsMethods().createTransaction(
                                          user.id,
                                          accountId,
                                          date,
                                          description,
                                          merchant,
                                          amount,
                                          type,
                                          categoryId,
                                        );

                                        // Refresh user data
                                        final updatedUser = await HttpsMethods()
                                            .getUserByEmail(user.email);

                                        if (updatedUser != null) {
                                          Provider.of<UserProvider>(
                                            context,
                                            listen: false,
                                          ).setUser(updatedUser);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Transaction added successfully!',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to add transaction: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              );
                            },
                          );
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
