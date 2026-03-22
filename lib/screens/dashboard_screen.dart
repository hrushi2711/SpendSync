import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../repositories/card_repository.dart';
import '../repositories/transaction_repository.dart';
import '../providers/auth_provider.dart';
import '../utils/categories.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUserId;
    final txRepo = context.watch<TransactionRepository>();
    final transactions = txRepo.getByUserId(userId);
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    // Calculate summary data
    double totalSpend = 0;
    final Map<String, double> categoryBreakdown = {};
    final Map<String, double> monthlySpend = {};

    for (final tx in transactions) {
      totalSpend += tx.amount;
      categoryBreakdown[tx.category] =
          (categoryBreakdown[tx.category] ?? 0) + tx.amount;
      final yyyyMm = DateFormat('yyyy-MM').format(tx.date);
      monthlySpend[yyyyMm] = (monthlySpend[yyyyMm] ?? 0) + tx.amount;
    }

    final sortedCategories = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedMonths = monthlySpend.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      key: const ValueKey('dashboard'),
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your spending habits across all cards.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),

        // Summary cards row
        Row(
          children: [
            // Total Spend card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Spend',
                          style: TextStyle(
                            color: colorScheme.onPrimary.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.currency_rupee,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(totalSpend),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All time cumulative',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Top Category card
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Top Category',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.trending_up,
                                color: Colors.orange.shade600, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        sortedCategories.isNotEmpty
                            ? sortedCategories.first.key
                            : 'N/A',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sortedCategories.isNotEmpty
                            ? '${currencyFormat.format(sortedCategories.first.value)} spent'
                            : 'No data',
                        style: TextStyle(
                            color: colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Pie Chart — Category Breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 20),
                if (sortedCategories.isEmpty)
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No expense data yet',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 220,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 45,
                              sections: sortedCategories.map((e) {
                                final pct =
                                    (e.value / totalSpend * 100).round();
                                return PieChartSectionData(
                                  value: e.value,
                                  color: getCategoryColor(e.key),
                                  radius: 50,
                                  title: '$pct%',
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sortedCategories.take(5).map((e) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: getCategoryColor(e.key),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        e.key,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Bar Chart — Monthly Trend
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 20),
                if (sortedMonths.isEmpty)
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No monthly data yet',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: sortedMonths
                                .map((e) => e.value)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                currencyFormat.format(rod.toY),
                                TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '₹${(value / 1000).toStringAsFixed(0)}k',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= sortedMonths.length) {
                                  return const SizedBox.shrink();
                                }
                                final label = sortedMonths[idx].key;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    label.substring(5), // MM only
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: null,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: colorScheme.outlineVariant.withOpacity(0.3),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          sortedMonths.length,
                          (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: sortedMonths[i].value,
                                color: colorScheme.primary,
                                width: 24,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
