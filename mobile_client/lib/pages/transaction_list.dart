import 'package:budget_pal/main.dart';
import 'package:budget_pal/models/user.dart';
import 'package:budget_pal/util/https_methods.dart';
import 'package:budget_pal/widgets/transactions/add_transaction_dialog.dart';
import 'package:budget_pal/widgets/transactions/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import "../../providers/user_provider.dart";

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPage();
}

class _TransactionListPage extends State<TransactionListPage> {
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  void _openAddTransactionDialog(BuildContext context, dynamic user) {
    if (user.accounts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please create an account first')));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionDialog(
          accounts: user.accounts,
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

                  final updatedUser = await HttpsMethods().getUserByEmail(
                    user.email,
                  );

                  if (updatedUser != null) {
                    Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).setUser(updatedUser);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Transaction added successfully!'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add transaction: $e')),
                  );
                }
              },
        );
      },
    );
  }

  Future<void> _refreshUser(UserProvider userProvider, User currentUser) async {
    final updatedUser = await HttpsMethods().getUserByEmail(currentUser.email);
    if (updatedUser != null) {
      userProvider.setUser(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        if (user == null) {
          return Scaffold(body: Center(child: Text('No user found')));
        }

        double income = 0;
        double expense = 0;
        for (final t in user.recentTransactions) {
          if (t.type == "EXPENSE") {
            expense += t.amount;
          } else {
            income += t.amount;
          }
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Activity", style: textTheme.headlineMedium),
                      _AddButton(
                        onTap: () => _openAddTransactionDialog(context, user),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Income / Expense summary tiles
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: "Income",
                          amount: currencyFormat.format(income),
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.success,
                          background: AppColors.successBackground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: "Expenses",
                          amount: currencyFormat.format(expense),
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.danger,
                          background: AppColors.dangerBackground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Text("Recent Transactions", style: textTheme.titleMedium),
                  const SizedBox(height: 12),

                  if (user.recentTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No transactions found',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ...user.recentTransactions.map((transaction) {
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
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.add, color: AppColors.onPrimary, size: 22),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatTile({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            amount,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
