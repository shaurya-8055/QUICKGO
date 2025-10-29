import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/earnings_provider.dart';
import '../jobs/available_jobs_screen.dart';
import '../jobs/active_jobs_screen.dart';
import '../jobs/job_history_screen.dart';
import '../earnings/earnings_wallet_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/stats_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/recent_job_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final earningsProvider = Provider.of<EarningsProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      jobProvider.loadJobs(),
      earningsProvider.loadEarnings(),
    ]);
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(onRefresh: _handleRefresh, child: _buildBody()),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'WorkerPro',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Text(
                'Hello, ${authProvider.workerName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            },
          ),
        ],
      ),
      actions: [
        // Availability Toggle
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: InkWell(
                onTap: () => authProvider.toggleAvailability(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: authProvider.isAvailable
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: authProvider.isAvailable
                              ? AppColors.success
                              : AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        authProvider.isAvailable ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 11,
                          color: authProvider.isAvailable
                              ? AppColors.success
                              : AppColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Notifications
        IconButton(
          icon: const Badge(
            label: Text('3'),
            child: Icon(Icons.notifications_outlined),
          ),
          onPressed: () {
            // Navigate to notifications
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return _buildHomePage();
    } else if (_currentIndex == 1) {
      return _buildJobsPage();
    } else if (_currentIndex == 2) {
      return _buildEarningsPage();
    } else {
      return _buildProfilePage();
    }
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Consumer2<EarningsProvider, JobProvider>(
            builder: (context, earningsProvider, jobProvider, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: "Today's Earnings",
                            value:
                                '\$${earningsProvider.todayEarnings.toStringAsFixed(2)}',
                            icon: Icons.attach_money,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Active Jobs',
                            value: '${jobProvider.activeJobsCount}',
                            icon: Icons.work_outline,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Completed',
                            value: '${jobProvider.completedJobsCount}',
                            icon: Icons.check_circle_outline,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Rating',
                            value:
                                '${context.watch<AuthProvider>().workerRating.toStringAsFixed(1)}⭐',
                            icon: Icons.star_outline,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionCard(
                        title: 'Start Work',
                        icon: Icons.play_circle_outline,
                        color: AppColors.success,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AvailableJobsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QuickActionCard(
                        title: 'Schedule',
                        icon: Icons.calendar_today_outlined,
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ActiveJobsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionCard(
                        title: 'Earnings',
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.accent,
                        onTap: () {
                          setState(() => _currentIndex = 2);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QuickActionCard(
                        title: 'Support',
                        icon: Icons.support_agent_outlined,
                        color: AppColors.info,
                        onTap: () {
                          // Navigate to support
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent Jobs
          Consumer<JobProvider>(
            builder: (context, jobProvider, _) {
              final recentJobs = jobProvider.getRecentJobs(limit: 5);

              if (recentJobs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.work_off_outlined,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recent jobs',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Jobs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _currentIndex = 1);
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentJobs.length,
                    itemBuilder: (context, index) {
                      return RecentJobCard(
                        job: recentJobs[index],
                        onTap: () {
                          // Navigate to job detail
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildJobsPage() {
    return const JobHistoryScreen();
  }

  Widget _buildEarningsPage() {
    return const EarningsWalletScreen();
  }

  Widget _buildProfilePage() {
    return const ProfileScreen();
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'Jobs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Earnings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, _) {
        if (jobProvider.hasActiveJob) {
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActiveJobsScreen(),
                ),
              );
            },
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.navigation),
            label: const Text('Active Job'),
          );
        }

        return FloatingActionButton(
          onPressed: () {
            // Show SOS dialog
            _showSOSDialog();
          },
          backgroundColor: AppColors.error,
          child: const Icon(Icons.sos),
        );
      },
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text(
          'Are you in an emergency situation? This will alert support and emergency contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Trigger SOS
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'SOS Alert Sent! Support will contact you shortly.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }
}
