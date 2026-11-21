import 'package:budget_pal/models/budget.dart';
import 'package:budget_pal/widgets/budgets/add_budget_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditBudgetDialog extends StatefulWidget {
  final Budget budget;
  final Future<void> Function(
    String name,
    double limitAmount,
    String period,
    DateTime startDate,
    DateTime endDate,
    int categoryId,
  )
  onEdit;

  const EditBudgetDialog({
    super.key,
    required this.budget,
    required this.onEdit,
  });

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _limitAmountController;

  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  late String _selectedPeriod;
  late int _selectedCategoryId;

  final List<String> _budgetPeriods = ['WEEKLY', 'MONTHLY', 'YEARLY'];

  final Map<int, String> _categories = CategoryHelper.categoryNames;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget.name);
    _limitAmountController = TextEditingController(
      text: widget.budget.limitAmount.toString(),
    );
    _selectedStartDate = DateTime.parse(widget.budget.startDate);
    _selectedEndDate = DateTime.parse(widget.budget.endDate);
    _selectedPeriod = widget.budget.period;
    _selectedCategoryId = widget.budget.categoryId;
  }

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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final double limitAmount =
          double.tryParse(_limitAmountController.text) ?? 0.0;

      await widget.onEdit(
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
      title: Text('Edit Budget'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Budget Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _limitAmountController,
                decoration: InputDecoration(
                  labelText: 'Budget Limit',
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
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                decoration: InputDecoration(labelText: 'Period'),
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
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(labelText: 'Category'),
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Start Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedStartDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectStartDate(context),
              ),
              Divider(),
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
        ElevatedButton(onPressed: _handleSubmit, child: Text('Save Changes')),
      ],
    );
  }
}
