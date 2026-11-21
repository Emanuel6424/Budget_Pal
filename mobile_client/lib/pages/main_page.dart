import 'package:budget_pal/main.dart';
import 'package:budget_pal/pages/budget_list.dart';
import 'package:budget_pal/pages/transaction_list.dart';
import 'package:flutter/material.dart';
import 'account_list.dart';
// Page Imports for the bottom navi bar

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}

class _MainPageState extends State<MainPage> {
  int currentPage = 0;

  final List<Widget> pages = [
    // Page Widgets go here from imports
    AccountListPage(),
    TransactionListPage(),
    BudgetListPage(),
  ];

  final List<_NavItem> navItems = const [
    _NavItem(
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      "Accounts",
    ),
    _NavItem(Icons.receipt_long_outlined, Icons.receipt_long, "Activity"),
    _NavItem(Icons.track_changes_outlined, Icons.track_changes, "Budget"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentPage, children: pages),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: currentPage,
        items: navItems,
        onTap: (value) => setState(() => currentPage = value),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: isSelected
                            ? Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
