import 'package:budget_pal/main.dart';
import 'package:budget_pal/models/budget_status.dart';
import 'package:budget_pal/models/transaction.dart';
import 'package:budget_pal/util/https_methods.dart';
import 'package:budget_pal/widgets/transactions/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetDetailsPage extends StatefulWidget {
  final int budgetId;
  final String name;
  final int categoryId;

  const BudgetDetailsPage({
    super.key,
    required this.budgetId,
    required this.name,
    required this.categoryId,
  });

  @override
  State<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  BudgetStatus? status;
  List<Transaction> transactions = [];
  bool isLoading = true;
  String? error;

  // Map category IDs to icons (matching BudgetWidget).
  static const Map<int, IconData> categoryIcons = {
    1: Icons.shopping_cart,
    2: Icons.restaurant,
    3: Icons.directions_car,
    4: Icons.movie,
    5: Icons.lightbulb,
    6: Icons.medical_services,
    7: Icons.shopping_bag,
    8: Icons.home,
    9: Icons.attach_money,
    10: Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _loadBudgetDetails();
  }

  Future<void> _loadBudgetDetails() async {
    try {
      final results = await Future.wait([
        HttpsMethods().getBudgetStatus(widget.budgetId),
        HttpsMethods().getBudgetTransactions(widget.budgetId),
      ]);

      if (!mounted) return;
      setState(() {
        status = results[0] as BudgetStatus?;
        transactions = results[1] as List<Transaction>;
        isLoading = false;
        if (status == null) {
          error = "Budget not found";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Color _getProgressColor(double percentUsed) {
    if (percentUsed >= 95) return AppColors.danger;
    if (percentUsed >= 75) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text(error!, style: textTheme.bodyMedium))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BudgetSummaryCard(
                      status: status!,
                      categoryIcon:
                          categoryIcons[widget.categoryId] ?? Icons.category,
                      progressColor: _getProgressColor(status!.percentUsed),
                      currencyFormat: currencyFormat,
                    ),
                    const SizedBox(height: 28),

                    Text(
                      "Contributing Transactions",
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Expenses in this category between "
                      "${DateFormat.yMMMd().format(DateTime.parse(status!.startDate))} and "
                      "${DateFormat.yMMMd().format(DateTime.parse(status!.endDate))}",
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),

                    if (transactions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            "No transactions have contributed to this budget yet.",
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      ...transactions.map(
                        (transaction) => TransactionWidget(
                          date: transaction.date,
                          description: transaction.description,
                          categoryId: transaction.categoryId,
                          amount: transaction.amount,
                          type: transaction.type,
                          merchant: transaction.merchant,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  final BudgetStatus status;
  final IconData categoryIcon;
  final Color progressColor;
  final NumberFormat currencyFormat;

  const _BudgetSummaryCard({
    required this.status,
    required this.categoryIcon,
    required this.progressColor,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: (status.percentUsed / 100).clamp(0.0, 1.0),
                          strokeWidth: 7,
                          backgroundColor: AppColors.inputBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, size: 18, color: progressColor),
                          Text(
                            '${status.percentUsed.toStringAsFixed(0)}%',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(status.name, style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        "${currencyFormat.format(status.spent)} of ${currencyFormat.format(status.limit)}",
                        style: textTheme.labelMedium,
                      ),
                      Text(
                        '${currencyFormat.format(status.remaining)} left',
                        style: textTheme.bodySmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryStat(
                  label: "Limit",
                  value: currencyFormat.format(status.limit),
                ),
                _SummaryStat(
                  label: "Spent",
                  value: currencyFormat.format(status.spent),
                ),
                _SummaryStat(
                  label: "Remaining",
                  value: currencyFormat.format(status.remaining),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: textTheme.labelMedium),
      ],
    );
  }
}
