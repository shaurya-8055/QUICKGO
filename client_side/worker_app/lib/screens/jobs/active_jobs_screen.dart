import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../providers/job_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveJobsScreen extends StatefulWidget {
  const ActiveJobsScreen({super.key});

  @override
  State<ActiveJobsScreen> createState() => _ActiveJobsScreenState();
}

class _ActiveJobsScreenState extends State<ActiveJobsScreen> {
  @override
  void initState() {
    super.initState();
    _loadActiveJobs();
  }

  Future<void> _loadActiveJobs() async {
    await Provider.of<JobProvider>(context, listen: false).loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Jobs'),
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeJobs = jobProvider.jobs.where((job) {
            final status = job['status'] ?? '';
            return status == 'accepted' ||
                status == 'en_route' ||
                status == 'working';
          }).toList();

          if (activeJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active jobs',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accepted jobs will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadActiveJobs,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeJobs.length,
              itemBuilder: (context, index) {
                return _buildActiveJobCard(activeJobs[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveJobCard(Map<String, dynamic> job) {
    final jobId = job['id'] ?? '';
    final status = job['status'] ?? 'accepted';
    final serviceType = job['serviceType'] ?? 'General Service';
    final customerName = job['customerName'] ?? 'Customer';
    final customerPhone = job['customerPhone'] ?? '';
    final address = job['address'] ?? 'Address not provided';
    final price = job['price'] ?? 500.0;
    final startTime = job['startTime'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getServiceIcon(serviceType),
                    color: _getStatusColor(status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceType,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(status),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Customer Info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                if (customerPhone.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makeCall(customerPhone),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openWhatsApp(customerPhone),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('WhatsApp'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Navigation Button
            if (status == 'accepted' || status == 'en_route')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openNavigation(address),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate to Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Job Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Charge',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  if (startTime != null && status == 'working')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Started',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatElapsedTime(startTime),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status Action Buttons
            _buildStatusActions(jobId, status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    String label;
    Color color;

    switch (status) {
      case 'accepted':
        label = 'Accepted';
        color = AppColors.statusAccepted;
        break;
      case 'en_route':
        label = 'On the Way';
        color = AppColors.statusEnRoute;
        break;
      case 'working':
        label = 'Working';
        color = AppColors.statusWorking;
        break;
      default:
        label = status.toUpperCase();
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusActions(String jobId, String status) {
    switch (status) {
      case 'accepted':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateJobStatus(jobId, 'en_route'),
            icon: const Icon(Icons.directions_car),
            label: const Text('Start Journey'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        );

      case 'en_route':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateJobStatus(jobId, 'working'),
            icon: const Icon(Icons.play_circle),
            label: const Text('Start Work'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusWorking,
              foregroundColor: Colors.white,
            ),
          ),
        );

      case 'working':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCompleteJobDialog(jobId),
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete Job'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelJobDialog(jobId),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel Job'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.statusAccepted;
      case 'en_route':
        return AppColors.statusEnRoute;
      case 'working':
        return AppColors.statusWorking;
      default:
        return AppColors.primary;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'ac repair':
      case 'ac service':
        return Icons.ac_unit;
      case 'mobile repair':
        return Icons.smartphone;
      case 'electrician':
        return Icons.electrical_services;
      case 'plumber':
        return Icons.plumbing;
      case 'painter':
        return Icons.format_paint;
      case 'appliance repair':
        return Icons.kitchen;
      default:
        return Icons.build;
    }
  }

  String _formatElapsedTime(Timestamp startTime) {
    final start = startTime.toDate();
    final now = DateTime.now();
    final elapsed = now.difference(start);

    if (elapsed.inHours > 0) {
      return '${elapsed.inHours}h ${elapsed.inMinutes % 60}m ago';
    } else {
      return '${elapsed.inMinutes}m ago';
    }
  }

  Future<void> _updateJobStatus(String jobId, String newStatus) async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final success = await jobProvider.updateJobStatus(jobId, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Status updated successfully' : 'Failed to update status',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showCompleteJobDialog(String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Job'),
        content: const Text(
          'Are you sure you want to mark this job as completed? The payment will be processed after customer confirmation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateJobStatus(jobId, 'completed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showCancelJobDialog(String jobId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for cancellation:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                  ),
                );
                return;
              }

              Navigator.pop(context);
              final jobProvider =
                  Provider.of<JobProvider>(context, listen: false);
              await jobProvider.cancelJob(jobId, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cancel Job'),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make call')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // Remove any spaces or special characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open WhatsApp')),
        );
      }
    }
  }

  Future<void> _openNavigation(String address) async {
    // Use Google Maps for navigation
    final encodedAddress = Uri.encodeComponent(address);
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open navigation')),
        );
      }
    }
  }
}
