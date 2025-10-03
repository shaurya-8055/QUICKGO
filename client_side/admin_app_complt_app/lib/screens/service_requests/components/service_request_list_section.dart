import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import 'service_action_dialog.dart';

class ServiceRequestListSection extends StatelessWidget {
  const ServiceRequestListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final list = context.dataProvider.serviceRequests;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Requests (${list.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () {
                  context.dataProvider.getAllServiceRequests(showSnack: true);
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const Gap(defaultPadding),
          if (list.isEmpty)
            Container(
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.6),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 36, color: Colors.white38),
                  const Gap(8),
                  const Text('No service requests found',
                      style: TextStyle(color: Colors.white70)),
                  const Gap(12),
                  OutlinedButton.icon(
                    onPressed: () => context.dataProvider
                        .getAllServiceRequests(showSnack: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  )
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Preferred')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: list.map((sr) {
                  return DataRow(cells: [
                    DataCell(Text(sr.customerName ?? '-')),
                    DataCell(Text(sr.phone ?? '-')),
                    DataCell(Text(sr.category ?? '-')),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sr.preferredDate?.isNotEmpty == true 
                                ? sr.preferredDate!
                                : 'No date',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            sr.preferredTime?.isNotEmpty == true 
                                ? sr.preferredTime!
                                : 'No time',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(_StatusBadge(status: sr.status ?? 'pending')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          tooltip: 'Approve',
                          onPressed: sr.sId == null
                              ? null
                              : () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => ServiceActionDialog(
                                      serviceRequest: sr,
                                      action: 'approve',
                                    ),
                                  );
                                  if (result == true) {
                                    // Force refresh to ensure UI is updated
                                    await context.dataProvider.getAllServiceRequests();
                                  }
                                },
                          icon: const Icon(Icons.check_circle,
                              color: Colors.greenAccent),
                        ),
                        IconButton(
                          tooltip: 'In-Progress',
                          onPressed: sr.sId == null
                              ? null
                              : () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => ServiceActionDialog(
                                      serviceRequest: sr,
                                      action: 'in-progress',
                                    ),
                                  );
                                  if (result == true) {
                                    // Force refresh to ensure UI is updated
                                    await context.dataProvider.getAllServiceRequests();
                                  }
                                },
                          icon: const Icon(Icons.play_circle_fill,
                              color: Colors.amberAccent),
                        ),
                        IconButton(
                          tooltip: 'Completed',
                          onPressed: sr.sId == null
                              ? null
                              : () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => ServiceActionDialog(
                                      serviceRequest: sr,
                                      action: 'completed',
                                    ),
                                  );
                                  if (result == true) {
                                    // Force refresh to ensure UI is updated
                                    await context.dataProvider.getAllServiceRequests();
                                  }
                                },
                          icon: const Icon(Icons.task_alt,
                              color: Colors.lightBlueAccent),
                        ),
                        IconButton(
                          tooltip: 'Cancel',
                          onPressed: sr.sId == null
                              ? null
                              : () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => ServiceActionDialog(
                                      serviceRequest: sr,
                                      action: 'cancel',
                                    ),
                                  );
                                  if (result == true) {
                                    // Force refresh to ensure UI is updated
                                    await context.dataProvider.getAllServiceRequests();
                                  }
                                },
                          icon:
                              const Icon(Icons.cancel, color: Colors.redAccent),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            )
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color _colorFor(String s) {
    switch (s) {
      case 'approved':
        return Colors.greenAccent;
      case 'in-progress':
        return Colors.amberAccent;
      case 'completed':
        return Colors.lightBlueAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _iconFor(String s) {
    switch (s) {
      case 'approved':
        return Icons.check_circle;
      case 'in-progress':
        return Icons.play_circle_fill;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  String _displayText(String s) {
    switch (s) {
      case 'in-progress':
        return 'In Progress';
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return s.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _colorFor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colorFor(status).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconFor(status),
            size: 16,
            color: _colorFor(status),
          ),
          const SizedBox(width: 6),
          Text(
            _displayText(status),
            style: TextStyle(
              color: _colorFor(status),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
