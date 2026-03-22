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
    if (percentUsed >= 95) return Colors.red;
    if (percentUsed >= 75) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BudgetStatus?>(
      future: HttpsMethods().getBudgetStatus(budgetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text('Error loading budget'),
            ),
          );
        }

        final status = snapshot.data!;
        final progressColor = _getProgressColor(status.percentUsed);

        return Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and name
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        categoryIcons[categoryId] ?? Icons.category,
                        size: 28,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            period,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Spent and remaining amounts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currencyFormat.format(status.spent)} of ${currencyFormat.format(status.limit)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${currencyFormat.format(status.remaining)} left',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: status.percentUsed / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                SizedBox(height: 8),

                // Percentage used
                Text(
                  '${status.percentUsed.toStringAsFixed(0)}% used',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
