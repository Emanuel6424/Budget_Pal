import 'package:budget_pal/main.dart';
import 'package:budget_pal/models/account.dart';
import 'package:budget_pal/models/transaction.dart';
import 'package:budget_pal/pages/account_details.dart';
import 'package:budget_pal/widgets/transactions/transaction_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef TransactionEditCallback = Future<void> Function(
  int transactionId,
  int accountId,
  DateTime date,
  String description,
  String merchant,
  double amount,
  String type,
  int categoryId,
);

typedef TransactionDeleteCallback = Future<void> Function(int transactionId);

class TransactionWidget extends StatelessWidget {
  final Transaction transaction;
  final List<Account> accounts;
  final TransactionEditCallback? onEdit;
  final TransactionDeleteCallback? onDelete;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  TransactionWidget({
    super.key,
    required this.transaction,
    this.accounts = const [],
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String category = CategoryHelper.getCategoryName(transaction.categoryId);
    final isExpense = transaction.type == "EXPENSE";
    final statusColor = isExpense ? AppColors.danger : AppColors.success;
    final statusBackground = isExpense
        ? AppColors.dangerBackground
        : AppColors.successBackground;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TransactionDetailsDialog(
                transaction: transaction,
                accounts: accounts,
                onEdit: onEdit,
                onDelete: onDelete,
              );
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Icon(
                  isExpense ? Icons.trending_down : Icons.trending_up,
                  size: 20,
                  color: statusColor,
                ),
              ),

              const SizedBox(width: 16), // Add spacing here
              // Middle - Description and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.description, style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.MMMd().format(transaction.date),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Right side - Amount and category
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isExpense
                        ? "-${currencyFormat.format(transaction.amount)}"
                        : "+${currencyFormat.format(transaction.amount)}",
                    style: textTheme.titleMedium?.copyWith(color: statusColor),
                  ),
                  const SizedBox(height: 4),
                  Text(category, style: textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
