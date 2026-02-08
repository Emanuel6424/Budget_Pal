import 'package:budget_pal/widgets/accounts/add_account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/accounts/account_widget.dart';
import '../util/https_methods.dart';

import 'package:provider/provider.dart';
import "../../providers/user_provider.dart";

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No account found',
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          );
        }

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
                            Text(
                              "Total Balance: ${currencyFormat.format(user.totalBalance)}",
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddAccountDialog(
                                  onAdd: (name, type, accountNumber, balance) async {
                                    // Save the context and navigator before any async operations
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);
                                    final userProvider =
                                        Provider.of<UserProvider>(
                                          context,
                                          listen: false,
                                        );

                                    print("Name: $name");
                                    print("Type: $type");
                                    print("Account Number: $accountNumber");
                                    print("Balance: $balance");

                                    // Create the account
                                    await HttpsMethods().createAccount(
                                      name,
                                      type,
                                      accountNumber,
                                      balance,
                                      user.id,
                                    );

                                    // Re-fetch user using email
                                    final updatedUser = await HttpsMethods()
                                        .getUserByEmail(user.email);

                                    if (updatedUser != null) {
                                      // Use the saved references instead of context
                                      userProvider.setUser(updatedUser);

                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Account added successfully!',
                                          ),
                                        ),
                                      );
                                    } else {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to refresh accounts',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          },
                          child: Text("Add Account"),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    ...user.accounts
                        .map(
                          (account) => AccountWidget(
                            name: account.name,
                            type: account.type,
                            accountNumber: account.accountNumber,
                            balance: account.balance,
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
