import 'package:budget_pal/providers/user_provider.dart';
import 'package:budget_pal/widgets/budgets/budget_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (contect, userProvider, child) {
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
                          onPressed: () {},
                          child: Text("Add Budget"),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    ...user.budgets
                        .map(
                          (budget) => BudgetWidget(
                            budgetId: budget.id,
                            name: budget.name,
                            limitAmount: budget.limitAmount,
                            period: budget.period,
                            categoryId: budget.categoryId, // Add this
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
