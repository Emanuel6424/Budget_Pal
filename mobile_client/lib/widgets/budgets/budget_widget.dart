import 'package:budget_pal/main.dart';
import 'package:budget_pal/models/budget_status.dart';
import 'package:budget_pal/util/https_methods.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetWidget extends StatelessWidget {
  final int budgetId;
  final String name;
  final double limitAmount;
  final String period;
  final int categoryId;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  BudgetWidget({
    super.key,
    required this.budgetId,
    required this.name,
    required this.limitAmount,
    required this.period,
    required this.categoryId,
  });

  // Map category IDs to icons (matching your CategoryHelper)
  Map<int, IconData> categoryIcons = {
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

  Color _getProgressColor(double percentUsed) {
    if (percentUsed >= 95) return AppColors.danger;
    if (percentUsed >= 75) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder<BudgetStatus?>(
      future: HttpsMethods().getBudgetStatus(budgetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Error loading budget', style: textTheme.bodyMedium),
            ),
          );
        }

        final status = snapshot.data!;
        final progressColor = _getProgressColor(status.percentUsed);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress ring with percentage
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: (status.percentUsed / 100).clamp(0.0, 1.0),
                          strokeWidth: 6,
                          backgroundColor: AppColors.inputBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor,
                          ),
                        ),
                      ),
                      Text(
                        '${status.percentUsed.toStringAsFixed(0)}%',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            categoryIcons[categoryId] ?? Icons.category,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(name, style: textTheme.titleMedium),
                          ),
                        ],
                      ),
                      Text(period, style: textTheme.bodySmall),
                      const SizedBox(height: 10),
                      Text(
                        '${currencyFormat.format(status.spent)} of ${currencyFormat.format(status.limit)}',
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
          ),
        );
      },
    );
  }
}
