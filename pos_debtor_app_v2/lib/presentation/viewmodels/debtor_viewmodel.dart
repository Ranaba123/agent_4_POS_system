import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/debtor.dart';
import '../../data/models/settlement.dart';

class DebtorViewModel extends ChangeNotifier {
  late Box<Debtor> _box;

  List<Debtor> _debtors = [];
  List<Debtor> get debtors => _debtors;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Filter settings
  int _longPendingDaysThreshold = 30;
  int get longPendingDaysThreshold => _longPendingDaysThreshold;

  void setThreshold(int days) {
    _longPendingDaysThreshold = days;
    notifyListeners();
  }

  DebtorViewModel() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<Debtor>('debtors');
    _loadDebtors();
    _box.listenable().addListener(_loadDebtors); // Auto-update on changes
    _isLoading = false;
    notifyListeners();
  }

  void _loadDebtors() {
    _debtors = _box.values.toList();
    // Sort by most recent add by default
    _debtors.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    notifyListeners();
  }

  // CRUD Operations
  Future<void> addDebtor(Debtor debtor) async {
    // Record initial debt as a settlement entry
    if (debtor.amount > 0) {
      debtor.settlements.add(Settlement(
        amount: debtor.amount,
        date: debtor.dateAdded,
        notes: 'Initial Balance',
        type: 'debt',
      ));
    }
    await _box.add(debtor);
    _loadDebtors();
  }

  Future<void> updateDebtor(Debtor debtor) async {
    await debtor.save();
    _loadDebtors();
  }

  Future<void> deleteDebtor(Debtor debtor) async {
    await debtor.delete();
    _loadDebtors();
  }

  Future<void> markAsPaid(Debtor debtor) async {
    debtor.isPaid = true;
    debtor.amount = 0; // Ensure amount is 0 if manually paid
    await debtor.save();
    notifyListeners();
  }

  // Now handles both Payments and new Debts
  Future<void> addTransaction(Debtor debtor, double amount, String? notes,
      {bool isDebt = false}) async {
    final transaction = Settlement(
      amount: amount,
      date: DateTime.now(),
      notes: notes,
      type: isDebt ? 'debt' : 'payment',
    );

    debtor.settlements.add(transaction);

    if (isDebt) {
      debtor.amount += amount;
      debtor.isPaid = false; // Re-open if it was closed
    } else {
      // Payment logic
      if (amount > debtor.amount) {
        // Should have been validated in UI, but safety clamp
        amount = debtor.amount;
      }
      debtor.amount = (debtor.amount - amount).clamp(0.0, double.infinity);
      if (debtor.amount <= 0) {
        debtor.isPaid = true;
      }
    }

    await debtor.save();
    notifyListeners();
  }

  @Deprecated('Use addTransaction instead')
  Future<void> addSettlement(
      Debtor debtor, double amount, String? notes) async {
    await addTransaction(debtor, amount, notes, isDebt: false);
  }

  // Dashboard Stats
  double get totalOutstanding {
    return _debtors
        .where((d) => !d.isPaid)
        .fold(0, (sum, item) => sum + item.amount);
  }

  int get activeDebtorsCount {
    return _debtors.where((d) => !d.isPaid).length;
  }

  // Total Collected (Sum of all payments)
  double get totalCollected {
    double total = 0;
    for (var debtor in _debtors) {
      for (var settlement in debtor.settlements) {
        if (settlement.type == 'payment') {
          total += settlement.amount;
        }
      }
    }
    return total;
  }

  // Deprecated: maintained for backward compatibility inside view if used
  double get paidTotal => totalCollected;

  List<Debtor> get paidDebtors => _debtors.where((d) => d.isPaid).toList();

  // Settled List with Date Inference
  List<Map<String, dynamic>> get settledDebtorsWithDate {
    return paidDebtors.map((d) {
      DateTime? settledDate;
      if (d.settlements.isNotEmpty) {
        // Find last payment that likely closed it
        // We just take the latest transaction date for simplicity
        var sorted = List<Settlement>.from(d.settlements)
          ..sort((a, b) => b.date.compareTo(a.date));
        settledDate = sorted.first.date;
      } else {
        settledDate = d.dateAdded; // Fallback
      }
      return {'debtor': d, 'date': settledDate};
    }).toList();
  }

  // Today's Sales (Debts added today)
  double get todayAddedTotal {
    final now = DateTime.now();
    return _calculateTotal(now, now, 'debt');
  }

  // Today's Collections (Payments made today)
  double get todayCollected {
    final now = DateTime.now();
    return _calculateTotal(now, now, 'payment');
  }

  // This Month's Sales
  double get monthAddedTotal {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    return _calculateTotal(start, end, 'debt');
  }

  // This Month's Collections
  double get monthCollected {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    return _calculateTotal(start, end, 'payment');
  }

  // Outstanding amount expected to be repaid in the current month (Due date is in this month)
  double get outstandingThisMonth {
    final now = DateTime.now();
    return _debtors
        .where((d) =>
            !d.isPaid &&
            d.dueDate != null &&
            d.dueDate!.year == now.year &&
            d.dueDate!.month == now.month)
        .fold(0, (sum, item) => sum + item.amount);
  }

  // Helper for totals
  double _calculateTotal(DateTime start, DateTime end, String type) {
    double total = 0;

    // Normalize dates to remove time component for comparison if needed,
    // but typically strict comparison is fine.
    // For "Today", start and end might be same day.
    // Let's create strict day ranges.

    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);

    for (var d in _debtors) {
      for (var sItem in d.settlements) {
        if (sItem.type == type &&
            sItem.date.isAfter(s.subtract(const Duration(seconds: 1))) &&
            sItem.date.isBefore(e.add(const Duration(seconds: 1)))) {
          total += sItem.amount;
        }
      }
    }
    return total;
  }

  List<Debtor> get dueTodayDebtors {
    final now = DateTime.now();
    return _debtors.where((d) {
      if (d.isPaid || d.dueDate == null) return false;
      return d.dueDate!.year == now.year &&
          d.dueDate!.month == now.month &&
          d.dueDate!.day == now.day;
    }).toList();
  }

  List<Debtor> get overdueDebtors {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _debtors.where((d) {
      if (d.isPaid || d.dueDate == null) return false;
      return d.dueDate!.isBefore(todayStart);
    }).toList();
  }

  List<Debtor> get dueThisMonthDebtors {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);

    var list = _debtors.where((d) {
      if (d.isPaid || d.dueDate == null) return false;
      return d.dueDate!.isAfter(start.subtract(const Duration(days: 1))) &&
          d.dueDate!.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    // Sort by days remaining (closest first)
    list.sort((a, b) {
      return a.daysPending.compareTo(b.daysPending);
    });
    return list;
  }

  // REPORT TRANSACTIONS
  List<Map<String, dynamic>> getTransactions(String period) {
    // period: 'daily', 'weekly', 'monthly'
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (period == 'daily') {
      start = DateTime(now.year, now.month, now.day);
    } else if (period == 'weekly') {
      // Start of week (assuming Monday)
      start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
    } else {
      // Monthly
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }

    List<Map<String, dynamic>> transactions = [];
    for (var debtor in _debtors) {
      for (var settlement in debtor.settlements) {
        if (settlement.date
                .isAfter(start.subtract(const Duration(seconds: 1))) &&
            settlement.date.isBefore(end.add(const Duration(seconds: 1)))) {
          transactions.add({
            'debtorName': debtor.name,
            'amount': settlement.amount,
            'date': settlement.date,
            'type': settlement.type,
            'notes': settlement.notes
          });
        }
      }
    }
    transactions.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return transactions;
  }

  Map<String, double> getTransactionTotals(String period) {
    final txs = getTransactions(period);
    double sales = 0;
    double collected = 0;
    for (var t in txs) {
      if (t['type'] == 'debt') {
        sales += t['amount'];
      } else {
        collected += t['amount'];
      }
    }
    return {'sales': sales, 'collected': collected};
  }

  // Global Transaction History (All time)
  List<Map<String, dynamic>> get allTransactions {
    // Use helper with strict all-time logic if needed, or simple iteration
    // Implementing simply:
    List<Map<String, dynamic>> transactions = [];
    for (var debtor in _debtors) {
      for (var settlement in debtor.settlements) {
        transactions.add({
          'debtorName': debtor.name,
          'amount': settlement.amount,
          'date': settlement.date,
          'type': settlement.type,
          'notes': settlement.notes
        });
      }
    }
    transactions.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return transactions;
  }

  // Bulk Delete
  Future<void> deleteAllSettledDebtors() async {
    final paid = _debtors.where((d) => d.isPaid).toList();
    for (var d in paid) {
      await d.delete();
    }
    _loadDebtors();
  }

  // Filter & Search Logic
  List<Debtor> getFilteredDebtors(
      String query, String filterType, String sortType) {
    var list = _debtors.where((d) {
      final matchName = d.name.toLowerCase().contains(query.toLowerCase());
      final matchPhone = d.phone?.contains(query) ?? false;
      final matchesSearch = query.isEmpty || matchName || matchPhone;

      bool matchesFilter = true;
      if (filterType == 'overdue') {
        matchesFilter = !d.isPaid &&
            d.daysPending < 0; // Negative daysPending means overdue
      } else if (filterType == 'high_balance') {
        matchesFilter = !d.isPaid && d.amount > 1000;
      } else if (filterType == 'recently_active') {
        final now = DateTime.now();
        matchesFilter =
            d.settlements.any((s) => now.difference(s.date).inDays <= 7);
      } else {
        // Default 'all' usually implies all ACTIVE (stats usually separate paid)
        // But "Debtors List" might want to show everything?
        // Usually Debtors list is Active only unless filtered.
        // Let's hide Paid from main list unless searched?
        // Current logic in previous step was !isPaid.
        matchesFilter = !d.isPaid;
      }

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort
    if (sortType == 'balance_desc') {
      list.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (sortType == 'last_transaction') {
      list.sort((a, b) {
        final dateA =
            a.settlements.isNotEmpty ? a.settlements.last.date : a.dateAdded;
        final dateB =
            b.settlements.isNotEmpty ? b.settlements.last.date : b.dateAdded;
        return dateB.compareTo(dateA);
      });
    } else if (sortType == 'due_date_asc') {
      list.sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else if (sortType == 'name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    return list;
  }
}
