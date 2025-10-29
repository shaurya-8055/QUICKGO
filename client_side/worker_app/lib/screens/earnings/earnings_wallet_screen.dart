import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../providers/earnings_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class EarningsWalletScreen extends StatefulWidget {
  const EarningsWalletScreen({super.key});

  @override
  State<EarningsWalletScreen> createState() => _EarningsWalletScreenState();
}

class _EarningsWalletScreenState extends State<EarningsWalletScreen> {
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    await Provider.of<EarningsProvider>(context, listen: false).loadEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings & Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show transaction history
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEarnings,
        child: Consumer<EarningsProvider>(
          builder: (context, earningsProvider, _) {
            if (earningsProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Wallet Balance Card
                _buildWalletCard(earningsProvider),

                const SizedBox(height: 20),

                // Period Selector
                _buildPeriodSelector(),

                const SizedBox(height: 20),

                // Earnings Chart
                _buildEarningsChart(earningsProvider),

                const SizedBox(height: 20),

                // Quick Stats
                _buildQuickStats(earningsProvider),

                const SizedBox(height: 20),

                // Withdrawal Button
                _buildWithdrawalButton(earningsProvider),

                const SizedBox(height: 20),

                // Recent Transactions
                _buildRecentTransactions(earningsProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWalletCard(EarningsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
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
              const Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${provider.availableBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Earned',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${provider.totalEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Month',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${provider.monthEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodChip('Today', 'today'),
        const SizedBox(width: 8),
        _buildPeriodChip('Week', 'week'),
        const SizedBox(width: 8),
        _buildPeriodChip('Month', 'month'),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: FilterChip(
        label: Center(child: Text(label)),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedPeriod = value);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEarningsChart(EarningsProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(provider),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _getBottomTitle(value.toInt()),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _getBarGroups(provider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(EarningsProvider provider) {
    switch (_selectedPeriod) {
      case 'today':
        return provider.todayEarnings * 1.5;
      case 'week':
        return 5000;
      case 'month':
        return 20000;
      default:
        return 1000;
    }
  }

  String _getBottomTitle(int value) {
    if (_selectedPeriod == 'week') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return value < days.length ? days[value] : '';
    } else if (_selectedPeriod == 'month') {
      return 'W${value + 1}';
    }
    return '';
  }

  List<BarChartGroupData> _getBarGroups(EarningsProvider provider) {
    if (_selectedPeriod == 'week') {
      // Sample data for 7 days
      return List.generate(7, (index) {
        final earnings =
            (provider.weekEarnings / 7) * (0.8 + (index % 3) * 0.2);
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: earnings,
              color: AppColors.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        );
      });
    } else if (_selectedPeriod == 'month') {
      // Sample data for 4 weeks
      return List.generate(4, (index) {
        final earnings = provider.monthEarnings / 4;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: earnings,
              color: AppColors.primary,
              width: 24,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        );
      });
    }
    return [];
  }

  Widget _buildQuickStats(EarningsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Today',
            '₹${provider.todayEarnings.toStringAsFixed(0)}',
            Icons.today,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'This Week',
            '₹${provider.weekEarnings.toStringAsFixed(0)}',
            Icons.calendar_view_week,
            AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'This Month',
            '₹${provider.monthEarnings.toStringAsFixed(0)}',
            Icons.calendar_month,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalButton(EarningsProvider provider) {
    final canWithdraw = provider.availableBalance >= 500;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canWithdraw ? () => _showWithdrawalSheet(provider) : null,
        icon: const Icon(Icons.account_balance),
        label: const Text('Withdraw Money'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(EarningsProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Show all transactions
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ...provider.transactions.take(5).map((transaction) {
                return _buildTransactionTile(transaction);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    final type = transaction['type'] ?? 'earning';
    final amount = transaction['amount'] ?? 0.0;
    final description = transaction['description'] ?? 'Transaction';
    final isCredit = type == 'earning';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isCredit
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        child: Icon(
          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
          color: isCredit ? AppColors.success : AppColors.error,
        ),
      ),
      title: Text(
        description,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        transaction['date'] ?? 'Today',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Text(
        '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isCredit ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  void _showWithdrawalSheet(EarningsProvider provider) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController upiController = TextEditingController();
    String withdrawalMethod = 'upi';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Withdraw Money',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available: ₹${provider.availableBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Withdrawal Method
              const Text(
                'Withdrawal Method',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text('UPI'),
                      value: 'upi',
                      groupValue: withdrawalMethod,
                      onChanged: (value) {
                        setModalState(() => withdrawalMethod = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Bank'),
                      value: 'bank',
                      groupValue: withdrawalMethod,
                      onChanged: (value) {
                        setModalState(() => withdrawalMethod = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amount Input
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  hintText: 'Enter amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // UPI ID or Bank Selection
              if (withdrawalMethod == 'upi')
                TextField(
                  controller: upiController,
                  decoration: const InputDecoration(
                    labelText: 'UPI ID',
                    hintText: 'name@upi',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                const Text(
                  'Money will be transferred to your registered bank account',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount < 500) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Minimum withdrawal amount is ₹500'),
                        ),
                      );
                      return;
                    }

                    if (amount > provider.availableBalance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Insufficient balance'),
                        ),
                      );
                      return;
                    }

                    if (withdrawalMethod == 'upi' &&
                        upiController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter UPI ID'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    final bankDetails = <String, dynamic>{
                      'method': withdrawalMethod,
                      if (withdrawalMethod == 'upi')
                        'upiId': upiController.text.trim(),
                    };

                    final success = await provider.requestWithdrawal(
                      amount,
                      bankDetails,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Withdrawal request submitted'
                                : 'Failed to process request',
                          ),
                          backgroundColor:
                              success ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Request'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
