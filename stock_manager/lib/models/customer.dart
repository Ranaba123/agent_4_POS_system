class Customer {
  final int? id;
  final String name;
  final String phone;
  final String? photoPath;
  final bool synced;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.photoPath,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photo_path': photoPath,
      'synced': synced ? 1 : 0,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      photoPath: map['photo_path'] as String?,
      synced: map['synced'] == 1,
    );
  }
}
