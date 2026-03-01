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
  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
    final isDebit = widget.type == "DEBIT";
    final color = isDebit ? Colors.red : Colors.green;
    final bgColor = isDebit
        ? const Color.fromARGB(80, 244, 67, 54)
        : const Color.fromARGB(86, 76, 175, 79);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      borderRadius: BorderRadius.circular(30),
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDebit
                            ? "-${widget.currencyFormat.format(widget.amount)}"
                            : "+${widget.currencyFormat.format(widget.amount)}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
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
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _detailRow(Icons.storefront, "MERCHANT", widget.merchant),
                    Divider(color: Colors.grey[200], height: 1),
                    _detailRow(
                      Icons.label_outline,
                      "CATEGORY",
                      CategoryHelper.getCategoryName(widget.categoryId),
                    ),
                    Divider(color: Colors.grey[200], height: 1),
                    _detailRow(
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
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DESCRIPTION",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
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
