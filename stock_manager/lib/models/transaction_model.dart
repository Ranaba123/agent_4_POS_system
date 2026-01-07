enum TransactionType { credit, settlement }

class TransactionModel {
  final int? id;
  final int customerId;
  final double amount;
  final TransactionType type;
  final DateTime timestamp;
  final bool synced;
  final String? itemName;
  final double? itemQuantity;
  final String? notes;

  TransactionModel({
    this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.synced = false,
    this.itemName,
    this.itemQuantity,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'amount': amount,
      'type': type == TransactionType.credit ? 'CREDIT' : 'SETTLEMENT',
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
      'item_name': itemName,
      'item_quantity': itemQuantity,
      'notes': notes,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    // Safely parse amount
    double parsedAmount = 0.0;
    if (map['amount'] != null) {
      parsedAmount = (map['amount'] as num).toDouble();
    }
    
    // Safely parse timestamp
    DateTime parsedTimestamp = DateTime.now();
    if (map['timestamp'] != null && map['timestamp'] is String) {
      try {
        parsedTimestamp = DateTime.parse(map['timestamp']);
      } catch (e) {
        parsedTimestamp = DateTime.now();
      }
    }
    
    // Safely parse item_quantity
    double? parsedQuantity;
    if (map['item_quantity'] != null) {
      parsedQuantity = (map['item_quantity'] as num).toDouble();
    }
    
    return TransactionModel(
      id: map['id'] as int?,
      customerId: (map['customer_id'] as num?)?.toInt() ?? 0,
      amount: parsedAmount,
      type: map['type'] == 'CREDIT' ? TransactionType.credit : TransactionType.settlement,
      timestamp: parsedTimestamp,
      synced: map['synced'] == 1,
      itemName: map['item_name'] as String?,
      itemQuantity: parsedQuantity,
      notes: map['notes'] as String?,
    );
  }
}
