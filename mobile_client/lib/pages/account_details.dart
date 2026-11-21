import 'package:budget_pal/models/account.dart';
import 'package:budget_pal/models/transaction.dart';
import 'package:budget_pal/models/user.dart';
import 'package:budget_pal/util/https_methods.dart';
import 'package:budget_pal/widgets/accounts/edit_account_dialog.dart';
import 'package:budget_pal/widgets/common/confirm_delete_dialog.dart';
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

  Future<User?> _refreshUser(UserProvider userProvider, User currentUser) async {
    final updatedUser = await HttpsMethods().getUserByEmail(currentUser.email);
    if (updatedUser != null) {
      userProvider.setUser(updatedUser);
    }
    return updatedUser;
  }

  void _openEditAccountDialog(
    BuildContext context,
    UserProvider userProvider,
    User user,
    Account account,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return EditAccountDialog(
          account: account,
          onEdit: (name, accountNumber) async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);

            try {
              await HttpsMethods().updateAccount(
                account.id,
                user.id,
                name: name,
                accountNumber: accountNumber,
              );

              await _refreshUser(userProvider, user);

              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Account updated successfully!')),
              );
            } catch (e) {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Failed to update account: $e')),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _handleDeleteAccount(
    BuildContext context,
    UserProvider userProvider,
    User user,
    Account account,
  ) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: 'Delete Account',
      message:
          'Are you sure you want to delete "${account.name}"? This cannot be undone.',
    );

    if (!confirmed || !context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await HttpsMethods().deleteAccount(account.id, user.id);
      await _refreshUser(userProvider, user);

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Account deleted successfully!')),
      );
      navigator.pop();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
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
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _openEditAccountDialog(context, userProvider, user, account);
                  } else if (value == 'delete') {
                    _handleDeleteAccount(context, userProvider, user, account);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit Account')),
                  PopupMenuItem(value: 'delete', child: Text('Delete Account')),
                ],
              ),
            ],
          ),
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
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction History',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),

                            if (isLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (error != null)
                              Center(
                                child: Text(
                                  'Error: $error',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              )
                            else if (transactions == null ||
                                transactions!.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'No transactions found',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              )
                            else
                              ...transactions!.map((transaction) {
                                return TransactionWidget(
                                  transaction: transaction,
                                  accounts: user.accounts,
                                  onEdit:
                                      (
                                        transactionId,
                                        accountId,
                                        date,
                                        description,
                                        merchant,
                                        amount,
                                        type,
                                        categoryId,
                                      ) async {
                                        final scaffoldMessenger =
                                            ScaffoldMessenger.of(context);

                                        try {
                                          await HttpsMethods().updateTransaction(
                                            transactionId,
                                            user.id,
                                            accountId: accountId,
                                            date: date,
                                            description: description,
                                            merchant: merchant,
                                            amount: amount,
                                            type: type,
                                            categoryId: categoryId,
                                          );

                                          await _refreshUser(userProvider, user);
                                          await _fetchTransactions();

                                          scaffoldMessenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Transaction updated successfully!',
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to update transaction: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                  onDelete: (transactionId) async {
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);

                                    try {
                                      await HttpsMethods().deleteTransaction(
                                        transactionId,
                                        user.id,
                                      );

                                      await _refreshUser(userProvider, user);
                                      await _fetchTransactions();

                                      scaffoldMessenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Transaction deleted successfully!',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to delete transaction: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                          ],
                        ),
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
