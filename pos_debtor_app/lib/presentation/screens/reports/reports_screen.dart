import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../../data/models/debtor.dart'; // Add this import

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DebtorViewModel>(
      builder: (context, viewModel, child) {
        final paid = viewModel.paidDebtors;
        
        if (paid.isEmpty) {
          return const Center(child: Text("No payment history yet"));
        }

        paid.sort((a, b) => b.dateAdded.compareTo(a.dateAdded)); // Sort by date

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paid.length + 1, // +1 for header
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text("Payment History", style: Theme.of(context).textTheme.titleMedium),
              );
            }
            final debtor = paid[index - 1];
            return Card(
              color: Colors.grey.shade50,
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(debtor.name, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                trailing: Text(
                  NumberFormat.simpleCurrency().format(debtor.amount),
                   style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                subtitle: Text("Cleared"),
              ),
            );
          },
        );
      },
    );
  }
}
