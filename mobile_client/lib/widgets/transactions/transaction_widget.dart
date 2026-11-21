import 'package:budget_pal/main.dart';
import 'package:budget_pal/pages/account_details.dart';
import 'package:budget_pal/widgets/transactions/transaction_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionWidget extends StatelessWidget {
  final DateTime date;
  final String description;
  final int categoryId;
  final double amount;
  final String type;
  final String merchant;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  TransactionWidget({
    super.key,
    required this.date,
    required this.description,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.merchant,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String category = CategoryHelper.getCategoryName(categoryId);
    final isExpense = type == "EXPENSE";
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
                date: date,
                description: description,
                categoryId: categoryId,
                amount: amount,
                type: type,
                merchant: merchant,
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
                    Text(description, style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.MMMd().format(date),
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
                        ? "-${currencyFormat.format(amount)}"
                        : "+${currencyFormat.format(amount)}",
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
