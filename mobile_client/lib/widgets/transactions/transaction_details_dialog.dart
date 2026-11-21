import 'package:budget_pal/main.dart';
import 'package:budget_pal/pages/account_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsDialog extends StatefulWidget {
  final DateTime date;
  final String description;
  final int categoryId;
  final double amount;
  final String type;
  final String merchant;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  TransactionDetailsDialog({
    super.key,
    required this.date,
    required this.description,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.merchant,
  });

  @override
  State<TransactionDetailsDialog> createState() =>
      _TransactionDetailsDialogState();
}

class _TransactionDetailsDialogState extends State<TransactionDetailsDialog> {
  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDebit = widget.type == "DEBIT";
    final color = isDebit ? AppColors.danger : AppColors.success;
    final bgColor = isDebit
        ? AppColors.dangerBackground
        : AppColors.successBackground;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Icon(
                      isDebit ? Icons.trending_down : Icons.trending_up,
                      size: 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDebit ? "Payment" : "Deposit",
                        style: textTheme.labelSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDebit
                            ? "-${widget.currencyFormat.format(widget.amount)}"
                            : "+${widget.currencyFormat.format(widget.amount)}",
                        style: textTheme.displaySmall?.copyWith(color: color),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              // Detail fields in a subtle card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.categoryTint,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _detailRow(
                      context,
                      Icons.storefront,
                      "MERCHANT",
                      widget.merchant,
                    ),
                    Divider(color: AppColors.border, height: 1),
                    _detailRow(
                      context,
                      Icons.label_outline,
                      "CATEGORY",
                      CategoryHelper.getCategoryName(widget.categoryId),
                    ),
                    Divider(color: AppColors.border, height: 1),
                    _detailRow(
                      context,
                      Icons.calendar_month,
                      "DATE",
                      DateFormat.yMMMd().format(widget.date),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.categoryTint,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("DESCRIPTION", style: textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
