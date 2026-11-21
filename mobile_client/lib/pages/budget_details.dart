import 'package:budget_pal/main.dart';
import 'package:budget_pal/models/budget.dart';
import 'package:budget_pal/models/budget_status.dart';
import 'package:budget_pal/models/transaction.dart';
import 'package:budget_pal/models/user.dart';
import 'package:budget_pal/providers/user_provider.dart';
import 'package:budget_pal/util/https_methods.dart';
import 'package:budget_pal/widgets/budgets/edit_budget_dialog.dart';
import 'package:budget_pal/widgets/common/confirm_delete_dialog.dart';
import 'package:budget_pal/widgets/transactions/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  Future<void> _refreshUser(UserProvider userProvider, User currentUser) async {
    final updatedUser = await HttpsMethods().getUserByEmail(currentUser.email);
    if (updatedUser != null) {
      userProvider.setUser(updatedUser);
    }
  }

  void _openEditBudgetDialog(
    BuildContext context,
    UserProvider userProvider,
    User user,
    Budget budget,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return EditBudgetDialog(
          budget: budget,
          onEdit: (name, limitAmount, period, startDate, endDate, categoryId) async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);

            try {
              await HttpsMethods().updateBudget(
                budget.id,
                user.id,
                name: name,
                limitAmount: limitAmount,
                period: period,
                startDate: startDate,
                endDate: endDate,
                categoryId: categoryId,
              );

              await _refreshUser(userProvider, user);
              await _loadBudgetDetails();

              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Budget updated successfully!')),
              );
            } catch (e) {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Failed to update budget: $e')),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _handleDeleteBudget(
    BuildContext context,
    UserProvider userProvider,
    User user,
  ) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: 'Delete Budget',
      message:
          'Are you sure you want to delete "${widget.name}"? This cannot be undone.',
    );

    if (!confirmed || !context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await HttpsMethods().deleteBudget(widget.budgetId, user.id);
      await _refreshUser(userProvider, user);

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Budget deleted successfully!')),
      );
      navigator.pop();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to delete budget: $e')),
      );
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

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final budget = user?.budgets.firstWhere(
          (b) => b.id == widget.budgetId,
          orElse: () => Budget(
            id: widget.budgetId,
            name: widget.name,
            limitAmount: 0,
            period: 'MONTHLY',
            startDate: DateTime.now().toIso8601String(),
            endDate: DateTime.now().toIso8601String(),
            active: true,
            categoryId: widget.categoryId,
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.name),
            actions: user == null || budget == null
                ? null
                : [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEditBudgetDialog(context, userProvider, user, budget);
                        } else if (value == 'delete') {
                          _handleDeleteBudget(context, userProvider, user);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit Budget')),
                        PopupMenuItem(value: 'delete', child: Text('Delete Budget')),
                      ],
                    ),
                  ],
          ),
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
                              transaction: transaction,
                              accounts: user?.accounts ?? const [],
                              onEdit: user == null
                                  ? null
                                  : (
                                      transactionId,
                                      accountId,
                                      date,
                                      description,
                                      merchant,
                                      amount,
                                      type,
                                      categoryId,
                                    ) async {
                                      final scaffoldMessenger =
                                          ScaffoldMessenger.of(context);

                                      try {
                                        await HttpsMethods().updateTransaction(
                                          transactionId,
                                          user.id,
                                          accountId: accountId,
                                          date: date,
                                          description: description,
                                          merchant: merchant,
                                          amount: amount,
                                          type: type,
                                          categoryId: categoryId,
                                        );

                                        await _refreshUser(userProvider, user);
                                        await _loadBudgetDetails();

                                        scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Transaction updated successfully!',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to update transaction: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              onDelete: user == null
                                  ? null
                                  : (transactionId) async {
                                      final scaffoldMessenger =
                                          ScaffoldMessenger.of(context);

                                      try {
                                        await HttpsMethods().deleteTransaction(
                                          transactionId,
                                          user.id,
                                        );

                                        await _refreshUser(userProvider, user);
                                        await _loadBudgetDetails();

                                        scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Transaction deleted successfully!',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to delete transaction: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },
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
