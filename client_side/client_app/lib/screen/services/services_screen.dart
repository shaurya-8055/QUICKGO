import 'package:flutter/material.dart';
import 'service_booking_screen.dart';
import 'worker_discovery_screen.dart';
import '../home_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static final List<_ServiceCategory> _categories = [
    _ServiceCategory('AC Repair', Icons.ac_unit_rounded, Colors.blue),
    _ServiceCategory('Mobile Repair', Icons.phone_iphone_rounded, Colors.teal),
    _ServiceCategory('Appliance Repair', Icons.kitchen_rounded, Colors.indigo),
    _ServiceCategory(
        'Electrician', Icons.electrical_services_rounded, Colors.orange),
    _ServiceCategory('Plumber', Icons.plumbing_rounded, Colors.cyan),
    _ServiceCategory('Painter', Icons.format_paint_rounded, Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Home',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          ),
        ),
        title: const Text('Home Services'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search services (e.g., AC repair, electrician)',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                  ),
                ),
                onChanged: (text) {
                  // No live filter yet; kept for future expansion.
                },
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return _ServiceCard(
                    title: cat.title,
                    color: cat.color,
                    icon: cat.icon,
                    onTap: () => _showServiceOptions(context, cat.title),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceOptions(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.map_rounded, color: Colors.blue),
              title: const Text('Find Workers Nearby'),
              subtitle: const Text('View workers on map and filter by rating'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WorkerDiscoveryScreen(serviceCategory: category),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.calendar_today_rounded, color: Colors.green),
              title: const Text('Quick Booking'),
              subtitle: const Text('Book service without choosing worker'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceBookingScreen(category: category),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ServiceCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              bottom: -18,
              child: Icon(icon, size: 120, color: color.withOpacity(0.10)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCategory {
  final String title;
  final IconData icon;
  final Color color;
  const _ServiceCategory(this.title, this.icon, this.color);
}
