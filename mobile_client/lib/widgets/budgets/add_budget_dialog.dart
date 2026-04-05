// widgets/budgets/add_budget_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddBudgetDialog extends StatefulWidget {
  final Future<void> Function(
    String name,
    double limitAmount,
    String period,
    DateTime startDate,
    DateTime endDate,
    int categoryId,
  )
  onAdd;

  const AddBudgetDialog({super.key, required this.onAdd});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _limitAmountController = TextEditingController();

  DateTime _selectedStartDate = DateTime.now().copyWith(
    day: 1,
  ); // First day of current month
  DateTime _selectedEndDate = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    0,
  ); // Last day of current month

  String _selectedPeriod = 'MONTHLY';
  int _selectedCategoryId = 1;

  final List<String> _budgetPeriods = ['WEEKLY', 'MONTHLY', 'YEARLY'];

  final Map<int, String> _categories = CategoryHelper.categoryNames;

  @override
  void dispose() {
    _nameController.dispose();
    _limitAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        // Auto-adjust end date based on period
        _adjustEndDate();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: _selectedStartDate,
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  void _adjustEndDate() {
    switch (_selectedPeriod) {
      case 'WEEKLY':
        _selectedEndDate = _selectedStartDate.add(Duration(days: 6));
        break;
      case 'MONTHLY':
        _selectedEndDate = DateTime(
          _selectedStartDate.year,
          _selectedStartDate.month + 1,
          0,
        );
        break;
      case 'YEARLY':
        _selectedEndDate = DateTime(_selectedStartDate.year, 12, 31);
        break;
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final double limitAmount =
          double.tryParse(_limitAmountController.text) ?? 0.0;

      await widget.onAdd(
        _nameController.text,
        limitAmount,
        _selectedPeriod,
        _selectedStartDate,
        _selectedEndDate,
        _selectedCategoryId,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Budget'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Budget Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Budget Name',
                  hintText: 'e.g., Monthly Groceries',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Limit Amount Field
              TextFormField(
                controller: _limitAmountController,
                decoration: InputDecoration(
                  labelText: 'Budget Limit',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a limit amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Period Dropdown
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                decoration: InputDecoration(
                  labelText: 'Period',
                  border: OutlineInputBorder(),
                ),
                items: _budgetPeriods.map((String period) {
                  return DropdownMenuItem<String>(
                    value: period,
                    child: Text(period),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPeriod = newValue;
                      _adjustEndDate();
                    });
                  }
                },
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategoryId = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 16),

              // Start Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Start Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedStartDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectStartDate(context),
              ),
              Divider(),

              // End Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('End Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedEndDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectEndDate(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: _handleSubmit, child: Text('Create Budget')),
      ],
    );
  }
}

class CategoryHelper {
  static const Map<int, String> categoryNames = {
    1: 'Groceries',
    2: 'Dining',
    3: 'Transportation',
    4: 'Entertainment',
    5: 'Utilities',
    6: 'Healthcare',
    7: 'Shopping',
    8: 'Housing',
    9: 'Income',
    10: 'Other',
  };

  static String getCategoryName(int id) {
    return categoryNames[id] ?? 'Unknown';
  }
}
