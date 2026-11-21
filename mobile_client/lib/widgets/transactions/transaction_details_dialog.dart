import 'package:budget_pal/main.dart';
import 'package:budget_pal/models/account.dart';
import 'package:budget_pal/models/transaction.dart';
import 'package:budget_pal/pages/account_details.dart';
import 'package:budget_pal/widgets/common/confirm_delete_dialog.dart';
import 'package:budget_pal/widgets/transactions/edit_transaction_dialog.dart';
import 'package:budget_pal/widgets/transactions/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsDialog extends StatefulWidget {
  final Transaction transaction;
  final List<Account> accounts;
  final TransactionEditCallback? onEdit;
  final TransactionDeleteCallback? onDelete;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  TransactionDetailsDialog({
    super.key,
    required this.transaction,
    this.accounts = const [],
    this.onEdit,
    this.onDelete,
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

  void _handleEdit() {
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (context) => EditTransactionDialog(
        transaction: widget.transaction,
        accounts: widget.accounts,
        onEdit:
            (accountId, date, description, merchant, amount, type, categoryId) =>
                widget.onEdit!(
                  widget.transaction.id,
                  accountId,
                  date,
                  description,
                  merchant,
                  amount,
                  type,
                  categoryId,
                ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: 'Delete Transaction',
      message:
          'Are you sure you want to delete this transaction? This cannot be undone.',
    );

    if (confirmed && context.mounted) {
      Navigator.of(context).pop();
      await widget.onDelete!(widget.transaction.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final transaction = widget.transaction;
    final isDebit = transaction.type == "DEBIT";
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
                            ? "-${widget.currencyFormat.format(transaction.amount)}"
                            : "+${widget.currencyFormat.format(transaction.amount)}",
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
                      transaction.merchant,
                    ),
                    Divider(color: AppColors.border, height: 1),
                    _detailRow(
                      context,
                      Icons.label_outline,
                      "CATEGORY",
                      CategoryHelper.getCategoryName(transaction.categoryId),
                    ),
                    Divider(color: AppColors.border, height: 1),
                    _detailRow(
                      context,
                      Icons.calendar_month,
                      "DATE",
                      DateFormat.yMMMd().format(transaction.date),
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
                      transaction.description,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.onEdit != null || widget.onDelete != null) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.onDelete != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                        ),
                        onPressed: _handleDelete,
                        child: const Text('Delete'),
                      ),
                    if (widget.onEdit != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleEdit,
                        child: const Text('Edit'),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
