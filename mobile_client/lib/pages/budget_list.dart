// pages/budgets_list.dart
import 'package:budget_pal/main.dart';
import 'package:budget_pal/models/notification.dart';
import 'package:budget_pal/providers/user_provider.dart';
import 'package:budget_pal/services/notification_service.dart';
import 'package:budget_pal/util/https_methods.dart';
import 'package:budget_pal/widgets/budgets/add_budget_dialog.dart'; // Add this import
import 'package:budget_pal/widgets/budgets/budget_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  final NotificationService _notificationService = NotificationService();
  List<BudgetNotification> _underspentNotifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  Future<void> _loadNotifications() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final notifications = await _notificationService.getNotifications(user.id);
    final unreadUnderspent = notifications
        .where((n) => n.type == 'BUDGET_UNDERSPENT' && n.isUnread)
        .toList();

    if (!mounted) return;
    setState(() {
      _underspentNotifications = unreadUnderspent;
    });
  }

  Future<void> _dismissNotification(BudgetNotification notification) async {
    final user = context.read<UserProvider>().user;
    setState(() {
      _underspentNotifications.removeWhere((n) => n.id == notification.id);
    });
    if (user != null) {
      await _notificationService.markRead(notification.id, user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No account found',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Budgets",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            "Track your spending",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddBudgetDialog(
                                  onAdd:
                                      (
                                        name,
                                        limitAmount,
                                        period,
                                        startDate,
                                        endDate,
                                        categoryId,
                                      ) async {
                                        try {
                                          // Call API to create budget
                                          await HttpsMethods().createBudget(
                                            user.id,
                                            name,
                                            limitAmount,
                                            period,
                                            startDate,
                                            endDate,
                                            categoryId,
                                          );

                                          // Refresh user data
                                          final updatedUser =
                                              await HttpsMethods()
                                                  .getUserByEmail(user.email);

                                          if (updatedUser != null) {
                                            Provider.of<UserProvider>(
                                              context,
                                              listen: false,
                                            ).setUser(updatedUser);

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Budget created successfully!',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to create budget: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                );
                              },
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.add,
                              color: AppColors.onPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ..._underspentNotifications.map(
                    (notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Dismissible(
                        key: ValueKey('notification-${notification.id}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _dismissNotification(notification),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.successBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close),
                        ),
                        child: Card(
                          color: AppColors.successBackground,
                          child: ListTile(
                            leading: const Icon(
                              Icons.savings,
                              color: AppColors.success,
                            ),
                            title: Text(notification.title),
                            subtitle: Text(notification.body),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (user.budgets.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No budgets found. Create your first budget!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ...user.budgets
                        .map(
                          (budget) => BudgetWidget(
                            budgetId: budget.id,
                            name: budget.name,
                            limitAmount: budget.limitAmount,
                            period: budget.period,
                            categoryId: budget.categoryId,
                          ),
                        )
                        .toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
