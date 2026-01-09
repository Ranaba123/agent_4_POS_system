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
  int get daysPending {
    final now = DateTime.now();
    return now.difference(dateAdded).inDays;
  }
  
  // Helper to check if it's long pending (e.g., > 30 days)
  bool isLongPending(int thresholdDays) {
    return daysPending > thresholdDays && !isPaid;
  }
}
