import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../../core/app_localization.dart';
import '../debtors/debtor_detail_screen.dart';
import '../../../data/models/debtor.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DebtorViewModel>(
      builder: (context, viewModel, child) {
        final loc = Provider.of<LocalizationProvider>(context).current;
        final now = DateTime.now();
        final currentMonth = DateFormat.MMMM().format(now); // e.g. January
        final currentYear = now.year.toString();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Outstanding Card
              _buildMainSummaryCard(context,
                  title: loc.translate('totalOutstanding'),
                  amount: viewModel.totalOutstanding,
                  expectedAmount: viewModel.outstandingThisMonth,
                  count: viewModel.activeDebtorsCount,
                  color: Theme.of(context).primaryColor,
                  monthLabel: "$currentMonth $currentYear"),
              const SizedBox(height: 24),

              // Daily & Monthly Stats Grid
              _buildDailyMonthlySection(context, viewModel, loc),

              const SizedBox(height: 32),

              // Upcoming Dues Section
              if (viewModel.dueThisMonthDebtors.isNotEmpty) ...[
                _buildSectionHeader(
                    context,
                    loc.translate('upcomingDues'),
                    Icons.calendar_today,
                    Colors.orange), // Renamed from dueThisMonth
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.dueThisMonthDebtors.take(5).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildDebtorTile(
                        context, viewModel.dueThisMonthDebtors[index], loc);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainSummaryCard(BuildContext context,
      {required String title,
      required double amount,
      required double expectedAmount,
      required int count,
      required Color color,
      required String monthLabel}) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');
    final loc = Provider.of<LocalizationProvider>(context).current;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)], // Solid branding
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("$count ${loc.translate('debtors')}",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currencyFormat.format(amount),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                height: 1.0), // Bigger font
          ),
          const SizedBox(height: 24),

          // Internal card for "Expected Repayment"
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('expectedRepaymentMonth'),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        "($monthLabel)", // Explicit Month Year
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(expectedAmount),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDailyMonthlySection(
      BuildContext context, DebtorViewModel viewModel, AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(context,
              title: loc.translate(
                  'dailyStats') /* Add to loc if missing, else 'Daily' */,
              sales: viewModel.todayAddedTotal,
              collected: viewModel.todayCollected,
              icon: Icons.today,
              color: Colors.blueAccent,
              labelSales: "Sales",
              labelCollected: "Collected"),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(context,
              title: loc.translate('monthlyStats') /* Add to loc if missing */,
              sales: viewModel.monthAddedTotal,
              collected: viewModel.monthCollected,
              icon: Icons.calendar_view_month,
              color: Colors.purpleAccent,
              labelSales: "Sales", // Could use loc.translate('sales')
              labelCollected: "Collected" // loc.translate('collected')
              ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
      required double sales,
      required double collected,
      required IconData icon,
      required Color color,
      required String labelSales,
      required String labelCollected}) {
    // final currencyFormat = NumberFormat.compactCurrency(symbol: 'Rs. '); // Compact for space

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatItem(context, labelSales, sales, Colors.orange),
          const SizedBox(height: 8),
          _buildStatItem(context, labelCollected, collected, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, double amount, Color color) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(currencyFormat.format(amount),
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
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
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDebtorTile(
      BuildContext context, Debtor debtor, AppLocalizations loc) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');
    final daysRemaining = debtor.daysPending;
    final isOverdue = daysRemaining < 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            16), // Ensures the left bar respects the corner radius
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: isOverdue ? Colors.red : Colors.orange,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                DebtorDetailScreen(debtor: debtor)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(debtor.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    isOverdue
                                        ? "${daysRemaining.abs()} ${loc.translate('days')} ${loc.translate('overdue')}"
                                        : "$daysRemaining ${loc.translate('days')} ${loc.translate('remaining')}",
                                    style: TextStyle(
                                      color:
                                          isOverdue ? Colors.red : Colors.grey,
                                      fontWeight: isOverdue
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(debtor.amount),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Actions Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Reminder Button
                            if (debtor.phone != null)
                              TextButton.icon(
                                onPressed: () {
                                  _sendWhatsAppReminder(debtor);
                                },
                                icon: const Icon(Icons.send, size: 16),
                                label: Text(loc.translate(
                                    'remind') /* Add 'Remind' to loc or use 'Send Reminder' */),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  foregroundColor: Colors.blue,
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            const SizedBox(width: 8),
                            // View Details Button (Small)
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => DebtorDetailScreen(
                                            debtor: debtor)));
                              },
                              icon: const Icon(Icons.visibility, size: 16),
                              label: Text(loc.translate(
                                  'details') /* Add 'Details' to loc */),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                foregroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendWhatsAppReminder(Debtor debtor) async {
    if (debtor.phone == null) return;
    // Basic WhatsApp URL intent
    final message =
        "Hello ${debtor.name}, a gentle reminder that your payment of Rs. ${debtor.amount} is due soon.";
    final url =
        "https://wa.me/${debtor.phone}?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
