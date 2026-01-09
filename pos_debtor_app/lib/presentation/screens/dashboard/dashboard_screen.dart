import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart'; // Import ThemeViewModel
import '../../../data/models/debtor.dart';
import '../debtors/debtor_detail_screen.dart'; // Will create this later

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DebtorViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context); // Access Theme VM
    final currencyFormat = NumberFormat.simpleCurrency(name: 'USD'); // Or generic symbol

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(themeViewModel.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeViewModel.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            context,
            title: "Total Outstanding",
            amount: viewModel.totalOutstanding,
            count: viewModel.activeDebtorsCount,
            color: Theme.of(context).colorScheme.primary,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  title: "Today's Debt",
                  value: currencyFormat.format(viewModel.todayAddedTotal),
                  icon: Icons.today,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  context,
                  title: "Paid Total",
                  value: currencyFormat.format(viewModel.paidTotal),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text("Top 5 Debtors", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (viewModel.top5DebtorsByAmount.isEmpty)
             const Card(
               child: Padding(
                 padding: EdgeInsets.all(24.0),
                 child: Center(child: Text("No debtors yet")),
               ),
             )
          else
            ...viewModel.top5DebtorsByAmount.map((debtor) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(debtor.name[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
                title: Text(debtor.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                trailing: Text(
                  currencyFormat.format(debtor.amount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                   // Navigate to detail
                   // Navigator.push(...)
                },
              ),
            )).toList(),
        ],
      ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {required String title, required double amount, required int count, required Color color, bool isPrimary = false}) {
    final currencyFormat = NumberFormat.simpleCurrency();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPrimary ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isPrimary ? Colors.white.withOpacity(0.9) : Theme.of(context).textTheme.bodyMedium?.color, // Adapt color
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(amount),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: isPrimary ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color, // Adapt color
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, color: isPrimary ? Colors.white70 : Theme.of(context).iconTheme.color, size: 20),
              const SizedBox(width: 8),
              Text(
                "$count Debtors",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isPrimary ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color, // Use theme card color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
