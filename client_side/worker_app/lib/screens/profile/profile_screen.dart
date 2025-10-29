import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/earnings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, EarningsProvider>(
        builder: (context, authProvider, earningsProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: authProvider.workerPhoto != null
                                ? NetworkImage(authProvider.workerPhoto!)
                                : null,
                            child: authProvider.workerPhoto == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.white,
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  // Upload photo
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.workerName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.accentLight,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${authProvider.workerRating.toStringAsFixed(1)} Rating',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: authProvider.isAvailable
                                  ? AppColors.success
                                  : AppColors.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              authProvider.isAvailable
                                  ? 'Available'
                                  : 'Offline',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Completed Jobs',
                          '${authProvider.completedJobs}',
                          Icons.check_circle,
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Earnings',
                          '₹${earningsProvider.totalEarnings.toStringAsFixed(0)}',
                          Icons.account_balance_wallet,
                          AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),

                // Personal Information
                _buildSection(
                  'Personal Information',
                  [
                    _buildInfoTile(
                      Icons.phone,
                      'Phone Number',
                      authProvider.workerPhone,
                    ),
                    _buildInfoTile(
                      Icons.email,
                      'Email',
                      authProvider.workerEmail.isNotEmpty
                          ? authProvider.workerEmail
                          : 'Not provided',
                    ),
                  ],
                ),

                // Indian Documents
                _buildSection(
                  'Documents (KYC)',
                  [
                    _buildInfoTile(
                      Icons.credit_card,
                      'Aadhar Number',
                      authProvider.workerData?['aadharNumber'] ??
                          'Not verified',
                      trailing: Icon(
                        authProvider.workerData?['aadharVerified'] == true
                            ? Icons.verified
                            : Icons.pending,
                        color:
                            authProvider.workerData?['aadharVerified'] == true
                                ? AppColors.success
                                : AppColors.warning,
                      ),
                    ),
                    _buildInfoTile(
                      Icons.account_balance,
                      'PAN Number',
                      authProvider.workerData?['panNumber'] ?? 'Not verified',
                      trailing: Icon(
                        authProvider.workerData?['panVerified'] == true
                            ? Icons.verified
                            : Icons.pending,
                        color: authProvider.workerData?['panVerified'] == true
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),

                // Bank Details
                _buildSection(
                  'Bank Details',
                  [
                    _buildInfoTile(
                      Icons.account_balance,
                      'Bank Name',
                      authProvider.workerData?['bankName'] ?? 'Not added',
                    ),
                    _buildInfoTile(
                      Icons.numbers,
                      'Account Number',
                      authProvider.workerData?['accountNumber'] ?? 'Not added',
                    ),
                    _buildInfoTile(
                      Icons.qr_code,
                      'IFSC Code',
                      authProvider.workerData?['ifscCode'] ?? 'Not added',
                    ),
                    _buildInfoTile(
                      Icons.payment,
                      'UPI ID',
                      authProvider.workerData?['upiId'] ?? 'Not added',
                    ),
                  ],
                ),

                // Service Areas
                _buildSection(
                  'Service Areas',
                  [
                    _buildInfoTile(
                      Icons.location_city,
                      'City',
                      authProvider.workerData?['city'] ?? 'Not set',
                    ),
                    _buildInfoTile(
                      Icons.location_on,
                      'Service Radius',
                      '${authProvider.workerData?['serviceRadius'] ?? 10} km',
                    ),
                  ],
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildActionButton(
                        'Earnings & Wallet',
                        Icons.account_balance_wallet,
                        AppColors.success,
                        () {
                          // Navigate to earnings
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'My Reviews',
                        Icons.star_rate,
                        AppColors.accent,
                        () {
                          // Navigate to reviews
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Help & Support',
                        Icons.support_agent,
                        AppColors.info,
                        () {
                          // Navigate to support
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Logout',
                        Icons.logout,
                        AppColors.error,
                        () {
                          _showLogoutDialog(context, authProvider);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.signOut();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
