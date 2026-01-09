import 'package:hive/hive.dart';

part 'settlement.g.dart';

@HiveType(typeId: 1)
class Settlement extends HiveObject {
  @HiveField(0)
  final double amount;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String? notes;

  @HiveField(3)
  final String type; // 'payment' or 'debt'

  Settlement({
    required this.amount,
    required this.date,
    this.notes,
    this.type = 'payment',
  });
}
