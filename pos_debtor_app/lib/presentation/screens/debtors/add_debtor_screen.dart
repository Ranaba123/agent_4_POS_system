import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../../data/models/debtor.dart';

class AddDebtorScreen extends StatefulWidget {
  const AddDebtorScreen({super.key});

  @override
  State<AddDebtorScreen> createState() => _AddDebtorScreenState();
}

class _AddDebtorScreenState extends State<AddDebtorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
      
      final newDebtor = Debtor(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        amount: amount,
        dateAdded: _selectedDate,
        dueDate: _dueDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await Provider.of<DebtorViewModel>(context, listen: false).addDebtor(newDebtor);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debtor added successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Debtor"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Customer Name",
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Amount Due",
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  if (double.tryParse(v) == null) return "Invalid number";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number (Optional)",
                  prefixIcon: Icon(Icons.phone_outlined),
                  counterText: "", // Hide character counter
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              const SizedBox(height: 16),
              
              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: _DatePickerButton(
                      label: "Date Added",
                      date: _selectedDate,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context, 
                          initialDate: _selectedDate, 
                          firstDate: DateTime(2020), 
                          lastDate: DateTime.now()
                        );
                        if (d != null) setState(() => _selectedDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerButton(
                      label: "Due Date",
                      date: _dueDate,
                      isOptional: true,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context, 
                          initialDate: _dueDate ?? DateTime.now(), 
                          firstDate: DateTime.now(), 
                          lastDate: DateTime(2030)
                        );
                        if (d != null) setState(() => _dueDate = d);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: "Notes (Optional)",
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text("Save Debtor"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool isOptional;

  const _DatePickerButton({required this.label, this.date, required this.onTap, this.isOptional = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  date != null ? DateFormat.yMMMd().format(date!) : "Set Date",
                  style: date != null 
                    ? Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87)
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
