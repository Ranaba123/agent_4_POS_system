import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../viewmodels/debtor_viewmodel.dart';
import '../../../data/models/debtor.dart';
import '../../../data/models/settlement.dart';

class DebtorDetailScreen extends StatefulWidget {
  final Debtor debtor;
  const DebtorDetailScreen({super.key, required this.debtor});

  @override
  State<DebtorDetailScreen> createState() => _DebtorDetailScreenState();
}

class _DebtorDetailScreenState extends State<DebtorDetailScreen> with SingleTickerProviderStateMixin {
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
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
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "History"),
          ],
        ),
      ),
      // Wrap body in Consumer to rebuild when ViewModel notifies of changes (e.g. added debt)
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
      // Use a Speed Dial or simple Row for two actions? 
      // User asked for "Add both settlement and adding more debt options on the same page"
      // A Bottom Sheet on FAB click is cleaner for mobile
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionOptions(context),
        label: const Text("Actions"),
        icon: const Icon(Icons.bolt),
      ),
    );
  }

  void _showTransactionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.red.shade100, child: const Icon(Icons.add, color: Colors.red)),
              title: const Text("Add More Debt"),
              subtitle: const Text("Increase outstanding amount"),
              onTap: () {
                Navigator.pop(ctx);
                _showTransactionDialog(context, isDebt: true);
              },
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.green.shade100, child: const Icon(Icons.attach_money, color: Colors.green)),
              title: const Text("Record Payment"),
              subtitle: const Text("Reduce outstanding amount"),
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
          top: 24
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDebt ? "Add New Debt" : "Record Payment", 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDebt ? Colors.red : Colors.green
                )
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixText: "\$ ",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  final amt = double.tryParse(value);
                  if (amt == null || amt <= 0) return "Invalid amount";
                  
                  if (!isDebt) {
                    // Payment Validation
                    if (amt > widget.debtor.amount) {
                      return "Cannot exceed outstanding: \$${widget.debtor.amount}";
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: "Note (Optional)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                          .addTransaction(widget.debtor, amount, noteController.text.trim().isEmpty ? null : noteController.text, isDebt: isDebt);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDebt ? Colors.red : Colors.green,
                  ),
                  child: Text(isDebt ? "Add Debt" : "Confirm Payment"),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Debtor"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Provider.of<DebtorViewModel>(context, listen: false).deleteDebtor(widget.debtor);
              Navigator.pop(ctx);
              Navigator.pop(context);
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Debtor debtor;
  const _OverviewTab({required this.debtor});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency();
    final dateFormat = DateFormat.yMMMd();

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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          
          Text("Amount Due", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(debtor.amount),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: debtor.amount > 0 ? Colors.redAccent : Colors.green, 
              fontWeight: FontWeight.bold
            ),
          ),
          
          const SizedBox(height: 32),
          
          _buildDetailRow(context, "Date Added", dateFormat.format(debtor.dateAdded)),
          if (debtor.dueDate != null) 
            _buildDetailRow(context, "Due Date", dateFormat.format(debtor.dueDate!)),
          _buildDetailRow(context, "Pending Days", "${debtor.daysPending} days"),
          
          if (debtor.notes != null && debtor.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Notes", style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Text(debtor.notes!, style: Theme.of(context).textTheme.bodyLarge),
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
          Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54)),
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
            const Text("No transactions recorded yet", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Sort by date desc
    final settlements = List<Settlement>.from(debtor.settlements)..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: settlements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = settlements[index];
        final isDebt = item.type == 'debt';
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12)
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDebt ? Colors.red.shade50 : Colors.green.shade50, 
              child: Icon(
                isDebt ? Icons.arrow_downward : Icons.arrow_upward, 
                color: isDebt ? Colors.red : Colors.green
              ),
            ),
            title: Text(
              NumberFormat.simpleCurrency().format(item.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isDebt ? Colors.red : Colors.green
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.yMMMd().format(item.date)),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      item.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
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
