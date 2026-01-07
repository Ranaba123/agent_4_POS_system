import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../services/database_helper.dart';
import '../services/localization_service.dart';
import '../services/app_theme.dart';
import '../models/customer.dart';
import 'calculator_screen.dart';
import 'add_customer_screen.dart';
import 'income_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppStrings strings;
  final bool isDarkMode;
  
  const HomeScreen({super.key, required this.strings, this.isDarkMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _customersWithBalance = [];
  double _totalOutstanding = 0.0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    
    try {
      final customers = await dbHelper.getCustomers();
      List<Map<String, dynamic>> enriched = [];
      double total = 0.0;

      for (var customer in customers) {
        final balance = await dbHelper.getCustomerBalance(customer.id!);
        enriched.add({'customer': customer, 'balance': balance});
        if (balance > 0) total += balance;
      }

      enriched.sort((a, b) => (b['balance'] as double).compareTo(a['balance'] as double));

      setState(() {
        _customersWithBalance = enriched;
        _totalOutstanding = total;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _showLanguageDialog() {
    final isDark = widget.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.strings.language, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('🇬🇧', widget.strings.english, 'en', isDark),
            _buildLanguageOption('🇱🇰', widget.strings.sinhala, 'si', isDark),
            _buildLanguageOption('🇱🇰', widget.strings.tamil, 'ta', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String name, String code, bool isDark) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name, style: GoogleFonts.poppins()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        AntiGravityPOS.setLocale(context, Locale(code));
        Navigator.pop(context);
      },
    );
  }

  void _showDeleteConfirmation(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: AppTheme.accentRed),
            ),
            const SizedBox(width: 12),
            Text(widget.strings.deleteCustomer, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(widget.strings.deleteCustomerConfirm, style: GoogleFonts.istokWeb()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCustomer(customer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
            ),
            child: Text(widget.strings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    try {
      await dbHelper.deleteCustomer(customer.id!);
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
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.strings.appTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Income Details (Analytics)
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: widget.strings.incomeDetails,
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IncomeDetailsScreen(strings: widget.strings, isDarkMode: isDark)),
              );
            },
          ),
          // Theme Toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            onPressed: () => AntiGravityPOS.toggleTheme(context),
          ),
          // Language
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: widget.strings.language,
            onPressed: _showLanguageDialog,
          ),
        ],
      ),
      body: _buildBody(isDark, primaryColor),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomerScreen(strings: widget.strings, isDarkMode: isDark)),
          );
          _refreshData();
        },
        label: Text(widget.strings.addCustomer, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildBody(bool isDark, Color primaryColor) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: AppTheme.accentRed),
              const SizedBox(height: 16),
              Text('Error: $_error', textAlign: TextAlign.center, style: GoogleFonts.istokWeb()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: Text('Retry', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      );
    }

    if (_customersWithBalance.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline, size: 80, color: primaryColor.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            Text(
              widget.strings.noCustomers,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              widget.strings.tapToAdd,
              style: GoogleFonts.istokWeb(color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSummaryCard(isDark),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
              itemCount: _customersWithBalance.length,
              itemBuilder: (context, index) {
                final item = _customersWithBalance[index];
                final Customer customer = item['customer'];
                final double balance = item['balance'];
                return _buildCustomerCard(customer, balance, index, isDark);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentRed,
            AppTheme.accentRed.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentRed.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.strings.totalOutstanding,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs. ${_totalOutstanding.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_customersWithBalance.length} ${_customersWithBalance.length == 1 ? 'customer' : 'customers'}',
            style: GoogleFonts.istokWeb(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, double balance, int index, bool isDark) {
    final bool hasDebt = balance > 0;
    final List<Color> cardColors = isDark
        ? [
            Colors.indigo.shade900,
            Colors.purple.shade900,
            Colors.teal.shade900,
            Colors.orange.shade900,
            Colors.pink.shade900,
          ]
        : [
            Colors.blue.shade50,
            Colors.purple.shade50,
            Colors.teal.shade50,
            Colors.orange.shade50,
            Colors.pink.shade50,
          ];
    
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;
    
    return Dismissible(
      key: Key('customer_${customer.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.accentRed,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text('Delete', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_outline, color: AppTheme.accentRed),
                ),
                const SizedBox(width: 12),
                Text(widget.strings.deleteCustomer, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ],
            ),
            content: Text(widget.strings.deleteCustomerConfirm, style: GoogleFonts.istokWeb()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(widget.strings.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  foregroundColor: Colors.white,
                ),
                child: Text(widget.strings.delete),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        _deleteCustomer(customer);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          elevation: isDark ? 0 : 2,
          shadowColor: Colors.black12,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => CalculatorScreen(
                    customer: customer,
                    strings: widget.strings,
                    isDarkMode: isDark,
                  ),
                ),
              );
              _refreshData();
            },
            onLongPress: () => _showDeleteConfirmation(customer),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profile Image
                  Hero(
                    tag: 'customer_${customer.id}',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: cardColors[index % cardColors.length],
                        borderRadius: BorderRadius.circular(16),
                        image: customer.photoPath != null
                            ? DecorationImage(
                                image: FileImage(File(customer.photoPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: customer.photoPath == null
                          ? Center(
                              child: Text(
                                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : (isDark ? AppTheme.primaryDark : AppTheme.primaryLight),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Customer Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: subtitleColor),
                            const SizedBox(width: 4),
                            Text(
                              customer.phone,
                              style: GoogleFonts.istokWeb(
                                fontSize: 16,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Balance
                  // Balance & Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: hasDebt 
                              ? AppTheme.accentRed.withOpacity(isDark ? 0.2 : 0.1) 
                              : AppTheme.accentGreen.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              hasDebt ? 'Owes' : 'Paid',
                              style: GoogleFonts.istokWeb(
                                fontSize: 11,
                                color: hasDebt ? AppTheme.accentRed : AppTheme.accentGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Rs. ${balance.abs().toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: hasDebt ? AppTheme.accentRed : AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _showDeleteConfirmation(customer),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.delete_outline, size: 24, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
