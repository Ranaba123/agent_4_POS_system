import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../../data/models/debtor.dart';
import '../../../core/app_localization.dart';

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
  late DateTime _dueDate; // Use late and init in initState

  @override
  void initState() {
    super.initState();
    _updateDueDate();
  }

  void _updateDueDate() {
    // Default: 1 month from added date (next month same day)
    _dueDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
  }

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
          SnackBar(content: Text(Provider.of<LocalizationProvider>(context, listen: false).current.translate('debtorAdded'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationProvider>(context).current;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('addNewDebtor')),
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
                decoration: InputDecoration(
                  labelText: loc.translate('customerName'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.isEmpty ? loc.translate('required') : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: loc.translate('amountDue'),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Text('Rs.', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return loc.translate('required');
                  if (double.tryParse(v) == null) return loc.translate('invalidNumber');
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: loc.translate('phoneNumber'),
                  prefixIcon: const Icon(Icons.phone_outlined),
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
                      label: loc.translate('dateAdded'),
                      date: _selectedDate,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context, 
                          initialDate: _selectedDate, 
                          firstDate: DateTime(2020), 
                          lastDate: DateTime.now()
                        );
                        if (d != null) {
                          setState(() {
                            _selectedDate = d;
                            _updateDueDate();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerButton(
                      label: loc.translate('dueDate'),
                      date: _dueDate,
                      isOptional: true,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context, 
                          initialDate: _dueDate, 
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
                decoration: InputDecoration(
                  labelText: loc.translate('notes'),
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(loc.translate('saveDebtor')),
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
