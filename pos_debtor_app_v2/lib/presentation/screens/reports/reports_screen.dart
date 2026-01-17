import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../../core/app_localization.dart';
import '../../../data/models/debtor.dart';
import '../debtors/debtor_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _transactionTabController;

  @override
  void initState() {
    super.initState();
    _transactionTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _transactionTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loc = Provider.of<LocalizationProvider>(context).current;

    return Consumer<DebtorViewModel>(
      builder: (context, viewModel, child) {
        final paid = viewModel.settledDebtorsWithDate; // Updated getter
        final overdue = viewModel.overdueDebtors;
        final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Overdue Accounts
              _buildSectionHeader(context, loc.translate('overdueAccounts'),
                  Icons.warning_amber_rounded, Colors.red),
              const SizedBox(height: 12),

              if (overdue.isEmpty)
                Card(
                  elevation: 0,
                  color: Theme.of(context).cardTheme.color,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                        child: Text(
                            loc.translate('noDebtorsDue') /* Reusing string */,
                            style: const TextStyle(color: Colors.green))),
                  ),
                )
              else
                SizedBox(
                  height: 180, // Height for card + call button
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: overdue.length,
                    itemBuilder: (context, index) {
                      final debtor = overdue[index];
                      return _buildOverdueCard(
                          context, debtor, currencyFormat, loc);
                    },
                  ),
                ),

              const SizedBox(height: 32),

              // 2. Transaction History with Tabs
              _buildSectionHeader(context, loc.translate('transactionHistory'),
                  Icons.history, Colors.blue),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _transactionTabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: const [
                        Tab(text: 'Daily'),
                        Tab(text: 'Weekly'),
                        Tab(text: 'Monthly'),
                      ],
                    ),
                    SizedBox(
                      height: 400, // Fixed height for list inside scroll view
                      child: TabBarView(
                        controller: _transactionTabController,
                        children: [
                          _buildTransactionList(
                              context, viewModel, 'daily', currencyFormat),
                          _buildTransactionList(
                              context, viewModel, 'weekly', currencyFormat),
                          _buildTransactionList(
                              context, viewModel, 'monthly', currencyFormat),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 3. Settled Accounts History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title in Green as requested
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      Text(loc.translate('settledHistory'),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                    ],
                  ),
                  if (paid.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _confirmDeleteAll(context),
                      icon: const Icon(Icons.delete_sweep, size: 18),
                      label: Text(loc.translate('deleteAll')),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (paid.isEmpty)
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(loc.translate('noSettledDebtors'),
                      style: const TextStyle(color: Colors.grey)),
                ))
              else
                ...paid.map((item) {
                  final debtor = item['debtor'] as Debtor;
                  final date = item['date'] as DateTime?;

                  return Card(
                    color: Theme.of(context).cardTheme.color, // Theme aware
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.green.withOpacity(0.2))),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: const Icon(Icons.check, color: Colors.green),
                      ),
                      title: InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DebtorDetailScreen(debtor: debtor))),
                        child: Text(debtor.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey)),
                      ),
                      subtitle: Text(
                          date != null
                              ? "Settled: ${DateFormat.yMMMd().format(date)}"
                              : loc.translate('cleared'),
                          style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Re-add Button
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.blue),
                            tooltip: loc.translate('addDebt'),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          DebtorDetailScreen(debtor: debtor)));
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _confirmDeleteOne(context, debtor),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DebtorDetailScreen(debtor: debtor)));
                      },
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTransactionList(BuildContext context, DebtorViewModel viewModel,
      String period, NumberFormat currencyFormat) {
    final transactions = viewModel.getTransactions(period);
    final totals = viewModel.getTransactionTotals(period);

    return Column(
      children: [
        // Summaries
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                  child: _buildMiniStat(
                      context, "Sales", totals['sales']!, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMiniStat(context, "Collected",
                      totals['collected']!, Colors.green)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: transactions.isEmpty
              ? const Center(child: Text("No transactions"))
              : ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    final isDebt = t['type'] == 'debt';
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isDebt ? Colors.red : Colors.green,
                        size: 18,
                      ),
                      title: InkWell(
                          onTap: () {
                            // Find debtor by name - simplistic but works if names unique or just for show
                            // Better: transaction list should carry debtor object.
                            // Current VM just mapped names.
                            var d = viewModel.debtors
                                .firstWhere((d) => d.name == t['debtorName']);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        DebtorDetailScreen(debtor: d)));
                          },
                          child: Text(t['debtorName'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      subtitle:
                          Text(DateFormat.yMMMd().add_jm().format(t['date'])),
                      trailing: Text(
                        currencyFormat.format(t['amount']),
                        style: TextStyle(
                            color: isDebt ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
      BuildContext context, String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(NumberFormat.compactCurrency(symbol: 'Rs. ').format(value),
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOverdueCard(BuildContext context, Debtor debtor,
      NumberFormat currencyFormat, AppLocalizations loc) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DebtorDetailScreen(debtor: debtor))),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.red.withOpacity(0.1)
              : Colors.red.shade50, // Dark Mode Fix
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.report, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(loc.translate('overdue'),
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
            Text(debtor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
            Text(
              currencyFormat.format(debtor.amount),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
            ),
            // Call Button
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton.icon(
                onPressed: debtor.phone != null
                    ? () async {
                        final Uri launchUri =
                            Uri(scheme: 'tel', path: debtor.phone);
                        if (await canLaunchUrl(launchUri))
                          await launchUrl(launchUri);
                      }
                    : null,
                icon: const Icon(Icons.call, size: 14),
                label: const Text("Call"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 12),
                  elevation: 0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    final loc =
        Provider.of<LocalizationProvider>(context, listen: false).current;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('deleteAll')),
        content: Text(loc.translate('deleteConfirmation')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.translate('cancel'))),
          TextButton(
            onPressed: () {
              Provider.of<DebtorViewModel>(context, listen: false)
                  .deleteAllSettledDebtors();
              Navigator.pop(ctx);
            },
            child: Text(loc.translate('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOne(BuildContext context, Debtor debtor) {
    final loc =
        Provider.of<LocalizationProvider>(context, listen: false).current;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('deleteDebtor')),
        content: Text(loc.translate('deleteConfirmation')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.translate('cancel'))),
          TextButton(
            onPressed: () {
              Provider.of<DebtorViewModel>(context, listen: false)
                  .deleteDebtor(debtor);
              Navigator.pop(ctx);
            },
            child: Text(loc.translate('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
