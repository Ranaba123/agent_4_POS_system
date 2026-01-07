import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import '../services/database_helper.dart';
import '../services/localization_service.dart';
import '../services/app_theme.dart';
import '../models/customer.dart';
import 'package:intl/intl.dart';

class IncomeDetailsScreen extends StatefulWidget {
  final AppStrings strings;
  final bool isDarkMode;

  const IncomeDetailsScreen({
    super.key,
    required this.strings,
    required this.isDarkMode,
  });

  @override
  State<IncomeDetailsScreen> createState() => _IncomeDetailsScreenState();
}

class _IncomeDetailsScreenState extends State<IncomeDetailsScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _topDebtors = [];
  List<BarChartGroupData> _monthlyGroups = [];
  List<String> _monthlyLabels = [];
  List<BarChartGroupData> _weeklyGroups = [];
  double _monthlyMaxY = 1000;
  double _weeklyMaxY = 1000;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final debtors = await dbHelper.getTopDebtors(5);
    final monthlyRaw = await dbHelper.getMonthlyStats();
    final weeklyRaw = await dbHelper.getWeeklyCreditStats();

    // Process Monthly Groups
    List<BarChartGroupData> mGroups = [];
    List<String> mLabels = [];
    double mMax = 0;
    
    // The query returns DESC (latest first), reverse for chronological chart
    final monthlyProcessed = monthlyRaw.reversed.toList();
    for (int i = 0; i < monthlyProcessed.length; i++) {
       final stat = monthlyProcessed[i];
       final double credit = (stat['total_credit'] as num).toDouble();
       final double settlement = (stat['total_settlement'] as num).toDouble();
       if (credit > mMax) mMax = credit;
       if (settlement > mMax) mMax = settlement;
       
       // Format "2024-05" -> "May"
       String label = "Month";
       try {
         final date = DateTime.parse("${stat['month']}-01");
         label = DateFormat('MMM').format(date);
       } catch (_) {}
       mLabels.add(label);

       mGroups.add(
         BarChartGroupData(
           x: i,
           barRods: [
             BarChartRodData(toY: credit, color: AppTheme.accentRed, width: 10, borderRadius: BorderRadius.circular(2)),
             BarChartRodData(toY: settlement, color: AppTheme.accentGreen, width: 10, borderRadius: BorderRadius.circular(2)),
           ]
         )
       );
    }

    // Process Weekly Groups (Ensure all 7 days are represented)
    List<BarChartGroupData> wGroups = [];
    double wMax = 0;
    Map<int, double> weeklyMap = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    for (var stat in weeklyRaw) {
      final int day = int.tryParse(stat['day_of_week'].toString()) ?? 0;
      final double credit = (stat['total_credit'] as num).toDouble();
      weeklyMap[day] = credit;
    }

    for (int i = 0; i < 7; i++) {
      final double val = weeklyMap[i]!;
      if (val > wMax) wMax = val;
      wGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: val, 
              color: AppTheme.primaryLight, 
              width: 22, 
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: val == 0 ? 0 : null, // Show empty space if 0
                color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              )
            )
          ]
        )
      );
    }

    if (mounted) {
      setState(() {
        _topDebtors = debtors;
        _monthlyGroups = mGroups;
        _monthlyLabels = mLabels;
        _weeklyGroups = wGroups;
        _monthlyMaxY = mMax > 0 ? (mMax < 100 ? 100 : mMax * 1.3) : 1000;
        _weeklyMaxY = wMax > 0 ? (wMax < 100 ? 100 : wMax * 1.3) : 1000;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.strings.incomeDetails, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                // Determine if we should use a single column or a grid-like layout for large screens
                bool isWide = constraints.maxWidth > 900;
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: isWide 
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildLeftColumn(textColor)),
                              const SizedBox(width: 24),
                              Expanded(flex: 3, child: _buildRightColumn(textColor)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopDebtorsSection(textColor),
                              const SizedBox(height: 32),
                              _buildMonthlyChartSection(textColor),
                              const SizedBox(height: 32),
                              _buildWeeklyChartSection(textColor),
                            ],
                          ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLeftColumn(Color textColor) {
    return Column(
      children: [
        _buildTopDebtorsSection(textColor),
      ],
    );
  }

  Widget _buildRightColumn(Color textColor) {
    return Column(
      children: [
        _buildMonthlyChartSection(textColor),
        const SizedBox(height: 32),
        _buildWeeklyChartSection(textColor),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
        Text(subtitle, style: GoogleFonts.istokWeb(fontSize: 14, color: textColor.withOpacity(0.7))),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTopDebtorsSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          widget.strings.topDebtors, 
          "Loku Naya Karayo - Call these people today!", 
          textColor
        ),
        if (_topDebtors.isEmpty)
          _buildEmptyCard("No debtors found. Great job!", textColor)
        else
          ..._topDebtors.map((data) => _buildDebtorRow(data, textColor)),
      ],
    );
  }

  Widget _buildDebtorRow(Map<String, dynamic> data, Color textColor) {
    final customer = Customer.fromMap(data);
    final double debt = (data['total_debt'] as num).toDouble();
    final double maxDebt = (_topDebtors.first['total_debt'] as num).toDouble();
    final double percentage = debt / (maxDebt == 0 ? 1 : maxDebt);
    
    // Smooth transition from Orange to Dark Red
    Color barColor = Color.lerp(AppTheme.accentOrange, const Color(0xFFB71C1C), (percentage - 0.2).clamp(0, 1))!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          Hero(
            tag: 'customer_photo_${customer.id}',
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                image: customer.photoPath != null
                  ? DecorationImage(image: FileImage(File(customer.photoPath!)), fit: BoxFit.cover)
                  : null,
              ),
              child: customer.photoPath == null
                ? Center(child: Text(customer.name[0].toUpperCase(), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)))
                : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(customer.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: textColor)),
                    Text('Rs. ${debt.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: barColor, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [barColor.withOpacity(0.7), barColor]),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [BoxShadow(color: barColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChartSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            widget.strings.monthlyStats, 
            "Naya vs. Berima - Are you running out of cash?", 
            textColor
        ),
        _buildChartContainer(
          child: Column(
            children: [
              _buildLegend([
                LegendItem(label: "Naya (Credit)", color: AppTheme.accentRed),
                LegendItem(label: "Berima (Settlement)", color: AppTheme.accentGreen),
              ], textColor),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 1.7,
                child: BarChart(
                  BarChartData(
                    maxY: _monthlyMaxY,
                    barGroups: _monthlyGroups,
                    alignment: BarChartAlignment.spaceAround,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (val, meta) {
                            if (val.toInt() >= 0 && val.toInt() < _monthlyLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(_monthlyLabels[val.toInt()], style: GoogleFonts.istokWeb(fontSize: 11, color: textColor.withOpacity(0.8), fontWeight: FontWeight.bold)),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.blueGrey.shade900,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            'Rs. ${rod.toY.toStringAsFixed(0)}',
                            GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }
                      )
                    )
                  ),
                ),
              ),
            ],
          ),
          textColor: textColor
        ),
      ],
    );
  }

  Widget _buildWeeklyChartSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            widget.strings.weeklyTrends, 
            "Weekly Rush - When are people most 'broke'?", 
            textColor
        ),
        _buildChartContainer(
          child: Column(
            children: [
              _buildLegend([
                LegendItem(label: "Credit Issuance (Naya)", color: AppTheme.primaryLight),
              ], textColor),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 1.7,
                child: BarChart(
                  BarChartData(
                    maxY: _weeklyMaxY,
                    barGroups: _weeklyGroups,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (val, meta) {
                            const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                            if (val.toInt() >= 0 && val.toInt() < 7) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(days[val.toInt()], style: GoogleFonts.istokWeb(fontSize: 11, color: textColor, fontWeight: FontWeight.w600)),
                              );
                            }
                            return const SizedBox();
                          },
                        )
                      ),
                       leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                         getTooltipColor: (_) => AppTheme.primaryLight.withOpacity(0.9),
                         getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              'Rs. ${rod.toY.toStringAsFixed(0)}',
                              GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                        }
                      )
                    )
                  ),
                ),
              ),
            ],
          ),
          textColor: textColor
        ),
      ],
    );
  }

  Widget _buildChartContainer({required Widget child, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ]
      ),
      child: child,
    );
  }

  Widget _buildEmptyCard(String message, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: textColor.withOpacity(0.1), width: 2, style: BorderStyle.solid)
      ),
      child: Center(child: Text(message, style: GoogleFonts.poppins(color: textColor.withOpacity(0.5)))),
    );
  }

  Widget _buildLegend(List<LegendItem> items, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 8),
            Text(item.label, style: GoogleFonts.istokWeb(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
          ],
        ),
      )).toList(),
    );
  }
}

class LegendItem {
  final String label;
  final Color color;
  LegendItem({required this.label, required this.color});
}
