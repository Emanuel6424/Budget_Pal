// pages/budgets_list.dart
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
                  const Text(
                    'No account found',
                    style: TextStyle(fontSize: 24, color: Colors.black),
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
          appBar: AppBar(title: Text("Budgets")),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Budgets",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Track your spending",
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
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
                          child: Text("+ Budget"),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

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
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close),
                          ),
                          child: Card(
                            color: Colors.green[50],
                            child: ListTile(
                              leading: const Icon(
                                Icons.savings,
                                color: Colors.green,
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
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No budgets found. Create your first budget!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
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
          ),
        );
      },
    );
  }
}
