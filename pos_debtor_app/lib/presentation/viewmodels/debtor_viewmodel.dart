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
  Future<void> addTransaction(Debtor debtor, double amount, String? notes, {bool isDebt = false}) async {
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
  Future<void> addSettlement(Debtor debtor, double amount, String? notes) async {
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
  
  double get paidTotal {
    return _debtors
        .where((d) => d.isPaid)
        .fold(0, (sum, item) => sum + item.amount);
  }
  
  List<Debtor> get paidDebtors => _debtors.where((d) => d.isPaid).toList();
  
  double get todayAddedTotal {
    final now = DateTime.now();
    return _debtors
        .where((d) => 
            d.dateAdded.year == now.year &&
            d.dateAdded.month == now.month &&
            d.dateAdded.day == now.day)
        .fold(0, (sum, item) => sum + item.amount);
  }

  // Top 5 Debtors
  List<Debtor> get top5DebtorsByAmount {
    var list = _debtors.where((d) => !d.isPaid).toList();
    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list.take(5).toList();
  }
  
  List<Debtor> get longPendingDebtors {
    return _debtors.where((d) => d.isLongPending(_longPendingDaysThreshold)).toList();
  }
}
