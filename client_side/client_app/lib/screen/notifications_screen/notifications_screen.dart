import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Mark all read',
            onPressed: () =>
                context.read<NotificationsProvider>().markAllRead(),
            icon: const Icon(Icons.done_all_rounded),
          ),
          IconButton(
            tooltip: 'Clear all',
            onPressed: () => context.read<NotificationsProvider>().clearAll(),
            icon: const Icon(Icons.clear_all_rounded),
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, np, _) {
          if (np.items.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: np.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = np.items[i];
              return Container(
                decoration: BoxDecoration(
                  color: n.read ? cs.surface : cs.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: n.read
                        ? Theme.of(context).dividerColor.withOpacity(0.15)
                        : cs.primary.withOpacity(0.25),
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.15),
                    foregroundColor: cs.primary,
                    child: const Icon(Icons.notifications_rounded),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _relativeTime(n.timestamp),
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} d ago';
  }
}
