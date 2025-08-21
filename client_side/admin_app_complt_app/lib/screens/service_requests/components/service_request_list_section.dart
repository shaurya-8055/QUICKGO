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
                    DataCell(Text(
                        '${sr.preferredDate ?? ''}  ${sr.preferredTime ?? ''}')),
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
                                    context.dataProvider
                                        .getAllServiceRequests();
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
                                    context.dataProvider
                                        .getAllServiceRequests();
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
                                    context.dataProvider
                                        .getAllServiceRequests();
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
                                    context.dataProvider
                                        .getAllServiceRequests();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _colorFor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colorFor(status).withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: _colorFor(status), fontWeight: FontWeight.w600),
      ),
    );
  }
}
