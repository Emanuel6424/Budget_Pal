import 'package:budget_pal/models/account.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionDialog extends StatefulWidget {
  final List<Account> accounts; // Add this
  final Function(
    int accountId, // Add accountId as first parameter
    DateTime date,
    String description,
    String merchant,
    double amount,
    String type,
    int categoryId,
  )
  onAdd;

  const AddTransactionDialog({
    super.key,
    required this.accounts, // Add this
    required this.onAdd,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields only
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'EXPENSE';
  int _selectedCategoryId = 1;
  late int _selectedAccountId; // Add this

  // Transaction type options
  final List<String> _transactionTypes = ['EXPENSE', 'INCOME'];

  // Category options (matching your backend)
  final Map<int, String> _categories = {
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

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.accounts.first.id; // Default to first account
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final double amount = double.tryParse(_amountController.text) ?? 0.0;

      widget.onAdd(
        _selectedAccountId, // Pass account ID
        _selectedDate,
        _descriptionController.text,
        _merchantController.text,
        amount,
        _selectedType,
        _selectedCategoryId,
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Transaction'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Account Dropdown (ADD THIS FIRST)
              DropdownButtonFormField<int>(
                value: _selectedAccountId,
                decoration: InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                ),
                items: widget.accounts.map((account) {
                  return DropdownMenuItem<int>(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedAccountId = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              // Date Picker
              ListTile(
                title: Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 8),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Merchant Field
              TextFormField(
                controller: _merchantController,
                decoration: InputDecoration(
                  labelText: 'Merchant',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a merchant';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Transaction Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: _transactionTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text('Add Transaction'),
        ),
      ],
    );
  }
}
