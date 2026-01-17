import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../viewmodels/navigation_viewmodel.dart';
import '../../../data/models/debtor.dart';
import '../../../data/models/settlement.dart';
import '../../../core/app_localization.dart';

class DebtorDetailScreen extends StatefulWidget {
  final Debtor debtor;
  const DebtorDetailScreen({super.key, required this.debtor});

  @override
  State<DebtorDetailScreen> createState() => _DebtorDetailScreenState();
}

class _DebtorDetailScreenState extends State<DebtorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.debtor.name),
        // Remove hardcoded colors to respect Theme
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          indicatorColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
                text: Provider.of<LocalizationProvider>(context)
                    .current
                    .translate('overview')),
            Tab(
                text: Provider.of<LocalizationProvider>(context)
                    .current
                    .translate('history')),
          ],
        ),
      ),
      // Wrap body in Consumer to rebuild when ViewModel notifies of changes
      body: Consumer<DebtorViewModel>(
        builder: (context, model, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(debtor: widget.debtor),
              _HistoryTab(debtor: widget.debtor),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionOptions(context),
        label: Text(Provider.of<LocalizationProvider>(context)
            .current
            .translate('actions')),
        icon: const Icon(Icons.bolt),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1, // Always Debtors tab
        onDestinationSelected: (index) {
          if (index != 1) {
            Provider.of<NavigationProvider>(context, listen: false)
                .setIndex(index);
            Navigator.of(context)
                .pop(); // Go back to MainScreen which will switch tab
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Debtors',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showTransactionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: const Icon(Icons.add, color: Colors.red)),
              title: Text(
                  Provider.of<LocalizationProvider>(context, listen: false)
                      .current
                      .translate('addMoreDebt')),
              subtitle: Text(
                  Provider.of<LocalizationProvider>(context, listen: false)
                      .current
                      .translate('increaseOutstanding')),
              onTap: () {
                Navigator.pop(ctx);
                _showTransactionDialog(context, isDebt: true);
              },
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.attach_money, color: Colors.green)),
              title: Text(
                  Provider.of<LocalizationProvider>(context, listen: false)
                      .current
                      .translate('recordPayment')),
              subtitle: Text(
                  Provider.of<LocalizationProvider>(context, listen: false)
                      .current
                      .translate('reduceOutstanding')),
              onTap: () {
                Navigator.pop(ctx);
                _showTransactionDialog(context, isDebt: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, {required bool isDebt}) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final loc =
        Provider.of<LocalizationProvider>(context, listen: false).current;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  isDebt
                      ? loc.translate('addNewDebt')
                      : loc.translate('recordPayment'),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: isDebt ? Colors.red : Colors.green)),
              const SizedBox(height: 16),
              if (isDebt && widget.debtor.dueDate != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        "${loc.translate('dueDate')}: ${DateFormat.yMMMd().format(widget.debtor.dueDate!)}",
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              TextFormField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: loc.translate('amount'),
                  prefixText: "Rs. ",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return loc.translate('required');
                  final amt = double.tryParse(value);
                  if (amt == null || amt <= 0)
                    return loc.translate('invalidNumber');

                  if (!isDebt) {
                    if (amt > widget.debtor.amount) {
                      return "Cannot exceed outstanding: Rs. ${widget.debtor.amount}";
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: loc.translate('notes'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final amount = double.parse(amountController.text);
                      Provider.of<DebtorViewModel>(context, listen: false)
                          .addTransaction(
                              widget.debtor,
                              amount,
                              noteController.text.trim().isEmpty
                                  ? null
                                  : noteController.text,
                              isDebt: isDebt);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDebt ? Colors.red : Colors.green,
                  ),
                  child: Text(isDebt
                      ? loc.translate('addDebt')
                      : loc.translate('confirmPayment')),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
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
                  .deleteDebtor(widget.debtor);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(loc.translate('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // Show dialog to edit name, due date, and phone
    final nameController = TextEditingController(text: widget.debtor.name);
    final phoneController = TextEditingController(text: widget.debtor.phone);
    DateTime? selectedDate = widget.debtor.dueDate;
    final loc =
        Provider.of<LocalizationProvider>(context, listen: false).current;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(loc.translate('editDebtor')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      InputDecoration(labelText: loc.translate('customerName')),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration:
                      InputDecoration(labelText: loc.translate('phoneNumber')),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(loc.translate('dueDate')),
                  subtitle: Text(selectedDate != null
                      ? DateFormat.yMMMd().format(selectedDate!)
                      : "Not Set"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setState(() => selectedDate = d);
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(loc.translate('cancel'))),
            TextButton(
              onPressed: () {
                widget.debtor.name = nameController.text;
                widget.debtor.phone =
                    phoneController.text.isEmpty ? null : phoneController.text;
                widget.debtor.dueDate = selectedDate;
                Provider.of<DebtorViewModel>(context, listen: false)
                    .updateDebtor(widget.debtor);
                Navigator.pop(ctx);
                super.setState(() {});
              },
              child: Text(loc.translate('saveChanges')),
            ),
          ],
        );
      }),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Debtor debtor;
  const _OverviewTab({required this.debtor});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');
    final dateFormat = DateFormat.yMMMd();
    final loc = Provider.of<LocalizationProvider>(context).current;

    DateTime? latestDebtDate;
    final debtSettlements =
        debtor.settlements.where((s) => s.type == 'debt').toList();
    if (debtSettlements.isNotEmpty) {
      debtSettlements.sort((a, b) => b.date.compareTo(a.date));
      latestDebtDate = debtSettlements.first.date;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFE0F2F1),
            child: Icon(Icons.person, size: 40, color: Color(0xFF00695C)),
          ),
          const SizedBox(height: 16),
          Text(
            debtor.name,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (debtor.phone != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final Uri launchUri = Uri(scheme: 'tel', path: debtor.phone);
                if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    debtor.phone!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Text(loc.translate('amountDue'),
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(debtor.amount),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: debtor.amount > 0 ? Colors.redAccent : Colors.green,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildDetailRow(context, loc.translate('dateAdded'),
              dateFormat.format(debtor.dateAdded)),
          if (latestDebtDate != null)
            _buildDetailRow(context, "Latest Debt Increase",
                dateFormat.format(latestDebtDate)),
          if (debtor.dueDate != null)
            _buildDetailRow(context, loc.translate('dueDate'),
                dateFormat.format(debtor.dueDate!)),
          _buildDetailRow(
              context,
              debtor.daysPending >= 0
                  ? loc.translate('daysUntilDue')
                  : loc.translate('overdueBy'),
              "${debtor.daysPending.abs()} ${loc.translate('days')}"),
          if (debtor.notes != null && debtor.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100, // Adaptive BG
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('notes'),
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Text(debtor.notes!,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Use Theme text styles for better Dark Mode support
          Text(label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final Debtor debtor;
  const _HistoryTab({required this.debtor});

  @override
  Widget build(BuildContext context) {
    if (debtor.settlements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
                Provider.of<LocalizationProvider>(context)
                    .current
                    .translate('noTransactions'),
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final settlements = List<Settlement>.from(debtor.settlements)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: settlements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = settlements[index];
        final isDebt = item.type == 'debt';

        return Card(
          elevation: 0,
          color: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDebt
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              child: Icon(isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isDebt ? Colors.red : Colors.green),
            ),
            title: Text(
              NumberFormat.currency(symbol: 'Rs. ').format(item.amount),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDebt ? Colors.red : Colors.green),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${DateFormat.yMMMd().format(item.date)} ${DateFormat.jm().format(item.date)}",
                    style: Theme.of(context).textTheme.bodySmall),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      item.notes!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
            isThreeLine: item.notes != null && item.notes!.isNotEmpty,
          ),
        );
      },
    );
  }
}
