import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../../data/models/debtor.dart';
import 'debtor_detail_screen.dart';
import '../../../core/app_localization.dart';

class DebtorListScreen extends StatefulWidget {
  const DebtorListScreen({super.key});

  @override
  State<DebtorListScreen> createState() => _DebtorListScreenState();
}

class _DebtorListScreenState extends State<DebtorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Filters removed as requested
  // String _filterType = 'all';
  String _sortType = 'balance_desc'; // Default

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationProvider>(context).current;

    return Column(
      children: [
        // Search & Sort Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: loc.translate('searchHint'),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
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
              const SizedBox(height: 12),
              // Sort Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Sorting Options only
                    _buildSortChip(
                        loc.translate('sort'),
                        _sortType,
                        [
                          'balance_desc',
                          'last_transaction',
                          'due_date_asc',
                          'name'
                        ],
                        (val) => setState(() => _sortType = val),
                        loc),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: Consumer<DebtorViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Pass 'all' as filter type since filters are removed
              final debtors =
                  viewModel.getFilteredDebtors(_searchQuery, 'all', _sortType);

              if (debtors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? loc.translate('noDebtorsYet')
                            : loc.translate('noMatches'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                // Added bottom padding to avoid FAB overlap
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                itemCount: debtors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
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

  Widget _buildSortChip(String label, String value, List<String> options,
      Function(String) onSelected, AppLocalizations loc) {
    String getLabel(String val) {
      switch (val) {
        case 'balance_desc':
          return loc.translate('balanceHighLow');
        case 'last_transaction':
          return loc.translate('lastTransaction');
        case 'due_date_asc':
          return loc.translate('dueDateAsc');
        case 'name':
          return loc.translate('nameAsc');
        default:
          return loc.translate('sort');
      }
    }

    return ActionChip(
      avatar: const Icon(Icons.sort, size: 16),
      label: Text(getLabel(value)),
      onPressed: () {
        _showSelectionSheet(context, options, getLabel, onSelected);
      },
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2))),
    );
  }

  void _showSelectionSheet(BuildContext context, List<String> options,
      String Function(String) labelBuilder, Function(String) onSelected) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options
                    .map((opt) => ListTile(
                          leading: _sortType == opt
                              ? Icon(Icons.check,
                                  color: Theme.of(context).primaryColor)
                              : const SizedBox(width: 24),
                          title: Text(labelBuilder(opt)),
                          onTap: () {
                            onSelected(opt);
                            Navigator.pop(ctx);
                          },
                        ))
                    .toList(),
              ),
            ));
  }
}

class _DebtorCard extends StatelessWidget {
  final Debtor debtor;
  const _DebtorCard({required this.debtor});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');
    final loc = Provider.of<LocalizationProvider>(context).current;

    // Subtitle Logic & Days Calculation
    String subtitle = "";
    Color subtitleColor = Colors.grey;
    final days = debtor
        .daysPending; // Assume this getter exists and returns (due - today)

    if (debtor.isPaid) {
      subtitle = loc.translate('cleared');
      subtitleColor = Colors.green;
    } else {
      if (days < 0) {
        subtitle =
            "${loc.translate('overdueBy')} ${days.abs()} ${loc.translate('days')}";
        subtitleColor = Colors.red;
      } else {
        subtitle = "${loc.translate('daysUntilDue')}: $days";
        subtitleColor = days <= 3 ? Colors.orange : Colors.green;
      }
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
          borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DebtorDetailScreen(debtor: debtor)));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: subtitleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debtor.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtitleColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(debtor.amount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  color: Colors.grey.withOpacity(0.5), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
