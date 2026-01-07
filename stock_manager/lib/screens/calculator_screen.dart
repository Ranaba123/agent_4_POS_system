import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/customer.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';
import '../services/localization_service.dart';
import '../services/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  final Customer customer;
  final AppStrings strings;
  final bool isDarkMode;
  
  const CalculatorScreen({
    super.key,
    required this.customer,
    required this.strings,
    this.isDarkMode = false,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '0';
  final dbHelper = DatabaseHelper();
  double _currentBalance = 0.0;
  bool _isProcessing = false;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final balance = await dbHelper.getCustomerBalance(widget.customer.id!);
    final transactions = await dbHelper.getTransactionsForCustomer(widget.customer.id!);
    setState(() {
      _currentBalance = balance;
      _transactions = transactions;
    });
  }

  void _onKeypadTap(String value) {
    setState(() {
      if (_input == '0' && value != '.') {
        _input = value;
      } else if (value == '.' && _input.contains('.')) {
        return;
      } else {
        _input += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_input.length > 1) {
        _input = _input.substring(0, _input.length - 1);
      } else {
        _input = '0';
      }
    });
  }

  void _onClear() {
    setState(() {
      _input = '0';
    });
  }

  void _showCreditDialog() {
    final double amount = double.tryParse(_input) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.strings.enterValidAmount, style: GoogleFonts.poppins()),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    final isDark = widget.isDarkMode;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final itemController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRed.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_upward, color: AppTheme.accentRed),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.strings.addCredit,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentRed,
                            ),
                          ),
                          Text(
                            'Rs. ${amount.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: itemController,
                label: widget.strings.itemName,
                hint: widget.strings.whatItem,
                icon: Icons.shopping_bag_outlined,
                isDark: isDark,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: quantityController,
                label: widget.strings.quantity,
                icon: Icons.numbers,
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: notesController,
                label: widget.strings.notes,
                icon: Icons.note_outlined,
                isDark: isDark,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                      child: Text(
                        widget.strings.cancel,
                        style: GoogleFonts.poppins(color: isDark ? Colors.white70 : null),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _processTransaction(
                          TransactionType.credit,
                          amount,
                          itemName: itemController.text.trim().isEmpty ? null : itemController.text.trim(),
                          quantity: double.tryParse(quantityController.text),
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(widget.strings.confirm, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettlementDialog() {
    final double amount = double.tryParse(_input) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.strings.enterValidAmount, style: GoogleFonts.poppins()),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    if (amount > _currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.strings.cannotExceedBalance, style: GoogleFonts.poppins()),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    final isDark = widget.isDarkMode;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_downward, color: AppTheme.accentGreen),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.strings.addSettlement,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                          Text(
                            'Rs. ${amount.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: notesController,
                label: widget.strings.notes,
                icon: Icons.note_outlined,
                isDark: isDark,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                      child: Text(
                        widget.strings.cancel,
                        style: GoogleFonts.poppins(color: isDark ? Colors.white70 : null),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _processTransaction(
                          TransactionType.settlement,
                          amount,
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(widget.strings.confirm, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? hint,
    int maxLines = 1,
    bool autofocus = false,
    TextInputType? keyboardType,
  }) {
    final primaryColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
    final cardColor = isDark ? AppTheme.darkSurface : Colors.grey.shade50;
    
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.istokWeb(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: isDark ? Colors.white60 : null),
        hintText: hint,
        hintStyle: GoogleFonts.istokWeb(color: isDark ? Colors.white30 : null),
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: cardColor,
      ),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Future<void> _processTransaction(
    TransactionType type,
    double amount, {
    String? itemName,
    double? quantity,
    String? notes,
  }) async {
    setState(() => _isProcessing = true);

    try {
      final transaction = TransactionModel(
        customerId: widget.customer.id!,
        amount: type == TransactionType.credit ? amount : -amount,
        type: type,
        timestamp: DateTime.now(),
        itemName: itemName,
        itemQuantity: quantity,
        notes: notes,
      );

      await dbHelper.insertTransaction(transaction);
      
      final newBalance = await dbHelper.getCustomerBalance(widget.customer.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  type == TransactionType.credit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(widget.strings.transactionSaved, style: GoogleFonts.poppins()),
              ],
            ),
            backgroundColor: type == TransactionType.credit ? AppTheme.accentRed : AppTheme.accentGreen,
          ),
        );
        setState(() => _input = '0');
        
        if (type == TransactionType.settlement && newBalance <= 0) {
          _showBalanceClearedDialog();
        } else {
          _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showBalanceClearedDialog() {
    final isDark = widget.isDarkMode;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.celebration, color: AppTheme.accentGreen, size: 28),
            ),
            const SizedBox(width: 12),
            Text(
              widget.strings.balanceCleared,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.accentGreen,
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.customer.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.strings.balanceClearedMsg,
              style: GoogleFonts.istokWeb(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData();
            },
            child: Text(widget.strings.keep, style: GoogleFonts.poppins()),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await dbHelper.deleteCustomer(widget.customer.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(widget.strings.customerDeleted, style: GoogleFonts.poppins()),
                      ],
                    ),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(widget.strings.remove, style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bool hasDebt = _currentBalance > 0;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Customer Header
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.customer.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'customer_${widget.customer.id}',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            image: widget.customer.photoPath != null
                                ? DecorationImage(
                                    image: FileImage(File(widget.customer.photoPath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: widget.customer.photoPath == null
                              ? Center(
                                  child: Text(
                                    widget.customer.name.isNotEmpty 
                                        ? widget.customer.name[0].toUpperCase() 
                                        : '?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 14, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  widget.customer.phone,
                                  style: GoogleFonts.istokWeb(color: Colors.white70),
                                ),
                              ],
                            ),
                            if (hasDebt) ...[
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () async {
                                  final phone = widget.customer.phone.replaceAll('+', '').replaceAll(' ', '');
                                  final message = widget.strings.whatsappMsg
                                      .replaceFirst('%s', widget.customer.name) // First %s is customer name
                                      .replaceFirst('%s', 'Naya Potha')       // Second %s is sender name
                                      .replaceFirst('%s', _currentBalance.toStringAsFixed(2)); // Third %s is amount
                                  
                                  final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Could not launch WhatsApp', style: GoogleFonts.poppins())),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.message, size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.strings.sendReminder,
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: hasDebt ? AppTheme.accentRed : AppTheme.accentGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rs. ${_currentBalance.abs().toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Calculator Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            color: cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Rs.',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _input,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Keypad
          Expanded(
            flex: 5,
            child: Container(
              color: cardColor,
              child: _buildKeypad(isDark, primaryColor),
            ),
          ),
          
          // Transaction History
          Expanded(
            flex: 3,
            child: _buildTransactionHistory(isDark, cardColor),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(bool isDark, Color primaryColor) {
    return Column(
      children: [
        Expanded(child: _buildKeyRow(['7', '8', '9', 'C'], isDark)),
        Expanded(child: _buildKeyRow(['4', '5', '6', '⌫'], isDark)),
        Expanded(child: _buildKeyRow(['1', '2', '3', ''], isDark)),
        Expanded(child: _buildKeyRow(['.', '0', '00', ''], isDark)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _showCreditDialog,
                    icon: const Icon(Icons.arrow_upward, size: 28),
                    label: Text(widget.strings.credit, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _showSettlementDialog,
                    icon: const Icon(Icons.arrow_downward, size: 28),
                    label: Text(widget.strings.settlement, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys, bool isDark) {
    final keyBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final specialKeyBgColor = isDark ? AppTheme.darkCard : Colors.grey.shade100;
    
    return Row(
      children: keys.map((key) {
        if (key.isEmpty) {
          return const Expanded(child: SizedBox());
        }
        
        final isSpecial = key == 'C' || key == '⌫';
        
        return Expanded(
          child: Container(
            margin: const EdgeInsets.all(4),
            child: Material(
              color: isSpecial ? specialKeyBgColor : keyBgColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (key == 'C') {
                    _onClear();
                  } else if (key == '⌫') {
                    _onBackspace();
                  } else {
                    _onKeypadTap(key);
                  }
                },
                child: Center(
                  child: Text(
                    key,
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: key == 'C' 
                          ? AppTheme.accentOrange 
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionHistory(bool isDark, Color cardColor) {
    final historyBgColor = isDark ? AppTheme.darkSurface : Colors.grey.shade50;
    final itemBgColor = isDark ? AppTheme.darkCard : Colors.white;
    
    return Container(
      decoration: BoxDecoration(
        color: historyBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.history, size: 20, color: isDark ? Colors.white54 : Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  widget.strings.transactionHistory,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 40, color: isDark ? Colors.white24 : Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          widget.strings.noTransactions,
                          style: GoogleFonts.istokWeb(color: isDark ? Colors.white38 : Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      final isCredit = tx.type == TransactionType.credit;
                      final dateFormat = DateFormat('dd MMM, HH:mm');
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: itemBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCredit 
                                    ? AppTheme.accentRed.withOpacity(isDark ? 0.2 : 0.1) 
                                    : AppTheme.accentGreen.withOpacity(isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isCredit ? AppTheme.accentRed : AppTheme.accentGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.itemName ?? (isCredit ? widget.strings.credit : widget.strings.settlement),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    dateFormat.format(tx.timestamp) +
                                        (tx.itemQuantity != null ? ' • Qty: ${tx.itemQuantity!.toStringAsFixed(0)}' : ''),
                                    style: GoogleFonts.istokWeb(
                                      fontSize: 12,
                                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isCredit ? '+' : ''}Rs. ${tx.amount.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                color: isCredit ? AppTheme.accentRed : AppTheme.accentGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
