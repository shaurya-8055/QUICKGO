import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../login_screen/provider/user_provider.dart';
import 'provider/service_provider.dart';
import '../../models/service_request.dart';

class MyServiceRequestsScreen extends StatefulWidget {
  const MyServiceRequestsScreen({super.key});

  @override
  State<MyServiceRequestsScreen> createState() =>
      _MyServiceRequestsScreenState();
}

class _MyServiceRequestsScreenState extends State<MyServiceRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = context.read<UserProvider>().getLoginUsr();
      context.read<ServiceProvider>().fetchMyRequests(user?.sId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Service Requests')),
      body: Consumer<ServiceProvider>(
        builder: (context, sp, _) {
          if (sp.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sp.myRequests.isEmpty) {
            return Center(
              child: Text('No service requests yet',
                  style: theme.textTheme.titleMedium),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: sp.myRequests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = sp.myRequests[i];
              return _RequestTile(r: r);
            },
          );
        },
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final ServiceRequest r;
  const _RequestTile({required this.r});

  Color _statusColor(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    switch (r.status) {
      case 'approved':
        return Colors.blue;
      case 'in-progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(r.category,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(r.status,
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(r.description ?? 'No description',
              style: TextStyle(color: theme.hintColor)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  size: 16, color: theme.hintColor),
              const SizedBox(width: 6),
              Text(
                  '${r.preferredDate.day}/${r.preferredDate.month}/${r.preferredDate.year} • ${r.preferredTime}',
                  style: TextStyle(color: theme.hintColor)),
            ],
          ),
          if (r.assigneeName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_rounded, size: 16, color: theme.hintColor),
                const SizedBox(width: 6),
                Text('${r.assigneeName} • ${r.assigneePhone ?? ''}',
                    style: TextStyle(color: theme.hintColor)),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
