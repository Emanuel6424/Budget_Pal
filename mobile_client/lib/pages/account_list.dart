import 'package:budget_pal/main.dart';
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

  void _openAddAccountDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddAccountDialog(
          onAdd: (name, type, accountNumber, balance) async {
            // Save the context and navigator before any async operations
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );

            // Create the account
            await HttpsMethods().createAccount(
              name,
              type,
              accountNumber,
              balance,
              user.id,
            );

            // Re-fetch user using email
            final updatedUser = await HttpsMethods().getUserByEmail(user.email);

            if (updatedUser != null) {
              // Use the saved references instead of context
              userProvider.setUser(updatedUser);

              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Account added successfully!')),
              );
            } else {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Failed to refresh accounts')),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No account found', style: textTheme.displaySmall),
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Accounts", style: textTheme.headlineMedium),
                      _AddButton(
                        onTap: () => _openAddAccountDialog(context, user),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hero balance card
                  _BalanceHeroCard(
                    label: "Total Balance",
                    amount: currencyFormat.format(user.totalBalance),
                    caption:
                        "${user.accounts.length} linked account"
                        "${user.accounts.length == 1 ? '' : 's'}",
                  ),
                  const SizedBox(height: 28),

                  Text("Your Accounts", style: textTheme.titleMedium),
                  const SizedBox(height: 12),

                  if (user.accounts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          "No accounts yet. Add one to get started.",
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ...user.accounts.map(
                      (account) => AccountWidget(
                        accountId: account.id,
                        name: account.name,
                        type: account.type,
                        accountNumber: account.accountNumber,
                        balance: account.balance,
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

class _BalanceHeroCard extends StatelessWidget {
  final String label;
  final String amount;
  final String caption;

  const _BalanceHeroCard({
    required this.label,
    required this.amount,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.onPrimary.withOpacity(0.75),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.onPrimary.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: const TextStyle(
              color: AppColors.onPrimary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              caption,
              style: TextStyle(
                color: AppColors.onPrimary.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
