import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/technician.dart';
import 'service_booking_screen.dart';

class TechnicianDetailScreen extends StatelessWidget {
  final Technician technician;

  const TechnicianDetailScreen({
    super.key,
    required this.technician,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(technician.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Profile
            Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: technician.profileImage != null
                              ? NetworkImage(technician.profileImage!)
                              : null,
                          child: technician.profileImage == null
                              ? Text(
                                  technician.name[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      technician.name,
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (technician.verified)
                                    const Icon(
                                      Icons.verified,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    technician.rating.toStringAsFixed(1),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${technician.totalJobs} jobs)',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${technician.yearsExperience} years experience',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (technician.pricePerHour != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.currency_rupee, size: 20),
                            Text(
                              '${technician.pricePerHour}/hr',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Skills
            if (technician.skills.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: technician.skills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            // Bio
            if (technician.bio != null && technician.bio!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      technician.bio!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Certifications
            if (technician.certifications != null &&
                technician.certifications!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...technician.certifications!.map((cert) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user,
                                size: 20, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child:
                                  Text(cert, style: theme.textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Availability Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: technician.currentlyAvailable == true
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    technician.currentlyAvailable == true
                        ? 'Available now'
                        : 'Currently busy',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // Space for bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                  onPressed: () => _makePhoneCall(technician.phone),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Book Service'),
                  onPressed: () => _bookService(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _bookService(BuildContext context) {
    // Navigate to booking screen with pre-filled technician info
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceBookingScreen(
          category: technician.skills.isNotEmpty
              ? technician.skills.first
              : 'General Service',
          preSelectedTechnician: technician,
        ),
      ),
    );
  }
}
