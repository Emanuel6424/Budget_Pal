import 'package:budget_pal/main.dart';
import 'package:budget_pal/pages/account_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class AccountWidget extends StatelessWidget {
  final int accountId;
  final String name;
  final String type;
  final String accountNumber;
  final double balance;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  AccountWidget({
    super.key,
    required this.accountId,
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountDetailsPage(accountId: accountId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accountTypeTints[type],
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(
                  accountTypeIcons[type],
                  size: 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: textTheme.titleMedium),
                    Text("$type • $accountNumber", style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(balance),
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textMuted,
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
