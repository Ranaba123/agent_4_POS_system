import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'naya_potha_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        photo_path TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        item_name TEXT,
        item_quantity REAL,
        notes TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');
  }

  // Customer CRUD
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    // Also delete related transactions
    await db.delete('transactions', where: 'customer_id = ?', whereArgs: [id]);
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<Customer?> getCustomerByPhone(String phone) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  // Transaction CRUD
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactionsForCustomer(int customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<double> getCustomerBalance(int customerId) async {
    try {
      final transactions = await getTransactionsForCustomer(customerId);
      return transactions.fold<double>(0.0, (sum, item) => sum + item.amount);
    } catch (e) {
      print('Error calculating balance: $e');
      return 0.0;
    }
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  // Analytics Methods

  Future<List<Map<String, dynamic>>> getTopDebtors(int limit) async {
    final db = await database;
    // Calculate sum of transactions for each customer
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.*, SUM(t.amount) as total_debt
      FROM customers c
      LEFT JOIN transactions t ON c.id = t.customer_id
      GROUP BY c.id
      HAVING total_debt > 0
      ORDER BY total_debt DESC
      LIMIT ?
    ''', [limit]);
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getMonthlyStats() async {
    final db = await database;
    // Group by Month (YYYY-MM)
    return await db.rawQuery('''
      SELECT strftime('%Y-%m', timestamp) as month,
             SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END) as total_credit,
             SUM(CASE WHEN type = 'settlement' THEN ABS(amount) ELSE 0 END) as total_settlement
      FROM transactions
      GROUP BY month
      ORDER BY month DESC
      LIMIT 12
    ''');
  }

  Future<List<Map<String, dynamic>>> getWeeklyCreditStats() async {
    final db = await database;
    // Get last 7 days stats
    return await db.rawQuery('''
      SELECT strftime('%w', timestamp) as day_of_week,
             SUM(amount) as total_credit
      FROM transactions
      WHERE type = 'credit' AND timestamp >= date('now', '-7 days')
      GROUP BY day_of_week
      ORDER BY day_of_week
    ''');
  }
}
