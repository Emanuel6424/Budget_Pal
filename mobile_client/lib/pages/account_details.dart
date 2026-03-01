import 'package:budget_pal/models/transaction.dart';
import 'package:budget_pal/util/https_methods.dart';
import 'package:budget_pal/widgets/transactions/account_header_widget.dart';
import 'package:budget_pal/widgets/transactions/transaction_widget.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import "../../providers/user_provider.dart";

class AccountDetailsPage extends StatefulWidget {
  final int accountId;

  const AccountDetailsPage({super.key, required this.accountId});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPage();
}

class _AccountDetailsPage extends State<AccountDetailsPage> {
  List<Transaction>? transactions;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final fetchedTransactions = await HttpsMethods().getTransactions(
        widget.accountId,
      );
      setState(() {
        transactions = fetchedTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        if (user == null) {
          return Scaffold(body: Center(child: Text('No user found')));
        }

        final account = user.accounts.firstWhere(
          (acc) => acc.id == widget.accountId,
          orElse: () => throw Exception('Account not found'),
        );

        return Scaffold(
          appBar: AppBar(title: Text(account.name)),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AccountHeaderWidget(
                    name: account.name,
                    type: account.type,
                    accountNumber: account.accountNumber,
                    balance: account.balance,
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
                            'Transaction History',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),

                          if (isLoading)
                            Center(child: CircularProgressIndicator())
                          else if (error != null)
                            Center(child: Text('Error: $error'))
                          else if (transactions == null ||
                              transactions!.isEmpty)
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
                            ...transactions!.map((transaction) {
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
