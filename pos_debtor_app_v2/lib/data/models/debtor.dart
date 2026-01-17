import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'settlement.dart';

part 'debtor.g.dart';

@HiveType(typeId: 0)
class Debtor extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? phone;

  @HiveField(3)
  double amount;

  @HiveField(4)
  DateTime dateAdded;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  bool isPaid;

  @HiveField(8)
  List<Settlement> settlements;

  Debtor({
    String? id,
    required this.name,
    this.phone,
    required this.amount,
    required this.dateAdded,
    this.dueDate,
    this.notes,
    this.isPaid = false,
    List<Settlement>? settlements,
  }) : id = id ?? const Uuid().v4(),
       settlements = settlements ?? [];

  // Helper for due days calculation
  // User Rule: due date - today's date 
  // If result is Positive: Days remaining until due.
  // If result is Negative: Days overdue.
  int get daysPending {
    final now = DateTime.now();
    if (dueDate != null) {
      final today = DateTime(now.year, now.month, now.day);
      final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
      return due.difference(today).inDays;
    }
    // Fallback if no due date, return days since added (as negative to imply "past" start?) 
    // Or just 0. Let's keep strict to request: due date - today.
    // If no due date, we can't calculate "due date - today". 
    // But maybe they want "how long outstanding"? 
    // Let's return 0 if null for safety or keep old behavior? 
    // Old behavior was: now - dateAdded. (Positive days since start).
    // If user wants "due - today", that is time remaining.
    // I will return 0 if null.
    return 0;
  }
  
  // Helper to check if it's long pending
  // If based on Due Date: Pending means "Overdue"?
  // Or "Long Pending" means "Start Date was long ago"?
  // Let's assume isLongPending checks if it is Overdue.
  bool isLongPending(int thresholdDays) {
     // This logic might need adjustment based on how it's used.
     // Currently only used in 'longPendingDebtors' list.
     // If we use due date, 'long pending' might mean 'overdue by threshold'.
     if (dueDate != null) {
       return daysPending < -thresholdDays && !isPaid;
     }
     // Fallback to old logic
     final now = DateTime.now();
     return now.difference(dateAdded).inDays > thresholdDays && !isPaid;
  }
}
