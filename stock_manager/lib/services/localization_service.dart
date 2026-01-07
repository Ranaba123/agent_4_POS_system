import 'dart:convert';
import 'package:flutter/services.dart';

class AppStrings {
  final String appTitle;
  final String totalOutstanding;
  final String addCustomer;
  final String name;
  final String phone;
  final String save;
  final String credit;
  final String settlement;
  final String whatsappMsg;
  final String highestDebt;
  final String takePhoto;
  final String selectGallery;
  final String noCustomers;
  final String tapToAdd;
  final String currentBalance;
  final String transactionSaved;
  final String enterValidAmount;
  final String language;
  final String english;
  final String sinhala;
  final String tamil;
  final String itemName;
  final String quantity;
  final String notes;
  final String addCredit;
  final String addSettlement;
  final String whatItem;
  final String howMuch;
  final String transactionHistory;
  final String noTransactions;
  final String cancel;
  final String confirm;
  final String deleteCustomer;
  final String deleteCustomerConfirm;
  final String delete;
  final String customerDeleted;
  final String balanceCleared;
  final String balanceClearedMsg;
  final String keep;
  final String remove;
  final String invalidPhoneError;
  final String cannotExceedBalance;
  final String customerExists;
  final String sendReminder;
  final String incomeDetails;
  final String topDebtors;
  final String monthlyStats;
  final String weeklyTrends;

  AppStrings({
    required this.appTitle,
    required this.totalOutstanding,
    required this.addCustomer,
    required this.name,
    required this.phone,
    required this.save,
    required this.credit,
    required this.settlement,
    required this.whatsappMsg,
    required this.highestDebt,
    required this.takePhoto,
    required this.selectGallery,
    required this.noCustomers,
    required this.tapToAdd,
    required this.currentBalance,
    required this.transactionSaved,
    required this.enterValidAmount,
    required this.language,
    required this.english,
    required this.sinhala,
    required this.tamil,
    required this.itemName,
    required this.quantity,
    required this.notes,
    required this.addCredit,
    required this.addSettlement,
    required this.whatItem,
    required this.howMuch,
    required this.transactionHistory,
    required this.noTransactions,
    required this.cancel,
    required this.confirm,
    required this.deleteCustomer,
    required this.deleteCustomerConfirm,
    required this.delete,
    required this.customerDeleted,
    required this.balanceCleared,
    required this.balanceClearedMsg,
    required this.keep,
    required this.remove,
    required this.invalidPhoneError,
    required this.cannotExceedBalance,
    required this.customerExists,
    required this.sendReminder,
    required this.incomeDetails,
    required this.topDebtors,
    required this.monthlyStats,
    required this.weeklyTrends,
  });

  factory AppStrings.defaults() {
    return AppStrings(
      appTitle: 'Naya Potha',
      totalOutstanding: 'Total Outstanding',
      addCustomer: 'Add Customer',
      name: 'Name',
      phone: 'Phone',
      save: 'Save',
      credit: 'Naya (Credit)',
      settlement: 'Settlement',
      whatsappMsg: 'Hello %s, this is a reminder from %s. Your outstanding balance is Rs. %s. Please settle at your earliest convenience. Thank you!',
      highestDebt: 'Highest Debt First',
      takePhoto: 'Take Photo',
      selectGallery: 'Select from Gallery',
      noCustomers: 'No customers yet',
      tapToAdd: 'Tap + to add your first customer',
      currentBalance: 'Current Balance',
      transactionSaved: 'Transaction saved!',
      enterValidAmount: 'Please enter a valid amount',
      language: 'Language',
      english: 'English',
      sinhala: 'සිංහල',
      tamil: 'தமிழ்',
      itemName: 'Item Name',
      quantity: 'Quantity',
      notes: 'Notes (Optional)',
      addCredit: 'Add Credit',
      addSettlement: 'Add Settlement',
      whatItem: 'What item?',
      howMuch: 'How much?',
      transactionHistory: 'Transaction History',
      noTransactions: 'No transactions yet',
      cancel: 'Cancel',
      confirm: 'Confirm',
      deleteCustomer: 'Delete Customer',
      deleteCustomerConfirm: 'Are you sure you want to delete this customer? This will also delete all their transaction history.',
      delete: 'Delete',
      customerDeleted: 'Customer deleted successfully',
      balanceCleared: 'Balance Cleared!',
      balanceClearedMsg: 'This customer has paid all their dues. Would you like to remove them from the list?',
      keep: 'Keep',
      remove: 'Remove',
      invalidPhoneError: 'Phone number must be 9 digits',
      cannotExceedBalance: 'Payment cannot exceed current balance',
      customerExists: 'Customer with this phone number already exists',
      sendReminder: 'Send Reminder',
      incomeDetails: 'Income Details',
      topDebtors: 'Top 5 Debtors (Loku Naya Karayo)',
      monthlyStats: 'Credit vs Settlements (Naya vs Salli)',
      weeklyTrends: 'Weekly Credit Trends (Rush)',
    );
  }

  factory AppStrings.fromJson(Map<String, dynamic> json) {
    return AppStrings(
      appTitle: json['app_title'] ?? 'Naya Potha',
      totalOutstanding: json['total_outstanding'] ?? 'Total Outstanding',
      addCustomer: json['add_customer'] ?? 'Add Customer',
      name: json['name'] ?? 'Name',
      phone: json['phone'] ?? 'Phone',
      save: json['save'] ?? 'Save',
      credit: json['credit'] ?? 'Naya (Credit)',
      settlement: json['settlement'] ?? 'Settlement',
      whatsappMsg: json['whatsapp_msg'] ?? '',
      highestDebt: json['highest_debt'] ?? 'Highest Debt First',
      takePhoto: json['take_photo'] ?? 'Take Photo',
      selectGallery: json['select_gallery'] ?? 'Select from Gallery',
      noCustomers: json['no_customers'] ?? 'No customers yet',
      tapToAdd: json['tap_to_add'] ?? 'Tap + to add your first customer',
      currentBalance: json['current_balance'] ?? 'Current Balance',
      transactionSaved: json['transaction_saved'] ?? 'Transaction saved!',
      enterValidAmount: json['enter_valid_amount'] ?? 'Please enter a valid amount',
      language: json['language'] ?? 'Language',
      english: json['english'] ?? 'English',
      sinhala: json['sinhala'] ?? 'සිංහල',
      tamil: json['tamil'] ?? 'தமிழ்',
      itemName: json['item_name'] ?? 'Item Name',
      quantity: json['quantity'] ?? 'Quantity',
      notes: json['notes'] ?? 'Notes (Optional)',
      addCredit: json['add_credit'] ?? 'Add Credit',
      addSettlement: json['add_settlement'] ?? 'Add Settlement',
      whatItem: json['what_item'] ?? 'What item?',
      howMuch: json['how_much'] ?? 'How much?',
      transactionHistory: json['transaction_history'] ?? 'Transaction History',
      noTransactions: json['no_transactions'] ?? 'No transactions yet',
      cancel: json['cancel'] ?? 'Cancel',
      confirm: json['confirm'] ?? 'Confirm',
      deleteCustomer: json['delete_customer'] ?? 'Delete Customer',
      deleteCustomerConfirm: json['delete_customer_confirm'] ?? 'Are you sure you want to delete this customer?',
      delete: json['delete'] ?? 'Delete',
      customerDeleted: json['customer_deleted'] ?? 'Customer deleted successfully',
      balanceCleared: json['balance_cleared'] ?? 'Balance Cleared!',
      balanceClearedMsg: json['balance_cleared_msg'] ?? 'This customer has paid all their dues. Would you like to remove them?',
      keep: json['keep'] ?? 'Keep',
      remove: json['remove'] ?? 'Remove',
      invalidPhoneError: json['invalid_phone_error'] ?? 'Phone number must be 9 digits',
      cannotExceedBalance: json['cannot_exceed_balance'] ?? 'Payment cannot exceed current balance',
      customerExists: json['customer_exists'] ?? 'Customer with this phone number already exists',
      sendReminder: json['send_reminder'] ?? 'Send Reminder',
      incomeDetails: json['income_details'] ?? 'Income Details',
      topDebtors: json['top_debtors'] ?? 'Top 5 Debtors',
      monthlyStats: json['monthly_stats'] ?? 'Monthly Stats',
      weeklyTrends: json['weekly_trends'] ?? 'Weekly Trends',
    );
  }
}

class LocalizationService {
  static Future<AppStrings> load(String languageCode) async {
    try {
      String jsonString = await rootBundle.loadString('assets/lang/$languageCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return AppStrings.fromJson(jsonMap);
    } catch (e) {
      print('Error loading localization for $languageCode: $e');
      return AppStrings.defaults();
    }
  }
}
