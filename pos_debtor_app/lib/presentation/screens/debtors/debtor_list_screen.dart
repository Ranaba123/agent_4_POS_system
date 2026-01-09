import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../../data/models/debtor.dart';
import 'add_debtor_screen.dart';
import 'debtor_detail_screen.dart';

class DebtorListScreen extends StatefulWidget {
  const DebtorListScreen({super.key});

  @override
  State<DebtorListScreen> createState() => _DebtorListScreenState();
}

class _DebtorListScreenState extends State<DebtorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search name, phone...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    }) 
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        // List
        Expanded(
          child: Consumer<DebtorViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final debtors = viewModel.debtors.where((d) {
                final matchName = d.name.toLowerCase().contains(_searchQuery);
                final matchPhone = d.phone?.contains(_searchQuery) ?? false;
                return !d.isPaid && (matchName || matchPhone); // Only show unpaid by default
              }).toList();

              if (debtors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                       const SizedBox(height: 16),
                       Text(
                         _searchQuery.isEmpty ? "No debtors found" : "No matches",
                         style: Theme.of(context).textTheme.bodyLarge,
                       ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: debtors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final debtor = debtors[index];
                  return _DebtorCard(debtor: debtor);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DebtorCard extends StatelessWidget {
  final Debtor debtor;
  const _DebtorCard({required this.debtor});

  Color _getStatusColor(int days) {
    if (days > 30) return Colors.red.shade100; // Old
    if (days > 15) return Colors.orange.shade100; // Medium
    return Colors.green.shade50; // New
  }
  
  Color _getAccentColor(int days) {
    if (days > 30) return Colors.red;
    if (days > 15) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency();
    final days = debtor.daysPending;
    final color = _getStatusColor(days);
    final accent = _getAccentColor(days);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200, width: 1),
        borderRadius: BorderRadius.circular(12)
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => DebtorDetailScreen(debtor: debtor)));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debtor.name, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      "$days days ago", 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent),
                    ),
                  ],
                ),
              ),
              
              // Amount
              Text(
                currencyFormat.format(debtor.amount),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
