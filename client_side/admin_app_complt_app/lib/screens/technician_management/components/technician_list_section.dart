import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';
import '../../service_requests/provider/technician_provider.dart';
import 'edit_technician_dialog.dart';

class TechnicianListSection extends StatelessWidget {
  const TechnicianListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TechnicianProvider>(
      builder: (context, provider, child) {
        final technicians = provider.technicians;

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
                      'Technicians (${technicians.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (provider.loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const Gap(defaultPadding),
              if (technicians.isEmpty)
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
                      const Icon(Icons.engineering_outlined,
                          size: 36, color: Colors.white38),
                      const Gap(8),
                      const Text('No technicians found',
                          style: TextStyle(color: Colors.white70)),
                      const Gap(12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            provider.getAllTechnicians(showSnack: true),
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
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Skills')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Created')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: technicians.map((technician) {
                      return DataRow(cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: technician.active == true
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: technician.active == true
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    technician.name ?? 'Unknown',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'ID: ${technician.sId?.substring(0, 8) ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          SelectableText(
                            technician.phone ?? 'N/A',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        DataCell(
                          Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: (technician.skills ?? [])
                                  .map((skill) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          skill,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        DataCell(
                            _StatusBadge(active: technician.active ?? false)),
                        DataCell(
                          Text(
                            _formatDate(technician.createdAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit Technician',
                                onPressed: technician.sId == null
                                    ? null
                                    : () async {
                                        final result = await showDialog<bool>(
                                          context: context,
                                          builder: (context) =>
                                              EditTechnicianDialog(
                                            technician: technician,
                                          ),
                                        );
                                        if (result == true) {
                                          provider.getAllTechnicians();
                                        }
                                      },
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                              ),
                              IconButton(
                                tooltip: technician.active == true
                                    ? 'Deactivate'
                                    : 'Activate',
                                onPressed: technician.sId == null
                                    ? null
                                    : () async {
                                        await provider.updateTechnician(
                                          id: technician.sId!,
                                          name: technician.name!,
                                          phone: technician.phone!,
                                          skills: technician.skills ?? [],
                                          active: !(technician.active ?? false),
                                        );
                                      },
                                icon: Icon(
                                  technician.active == true
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  color: technician.active == true
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete Technician',
                                onPressed: technician.sId == null
                                    ? null
                                    : () async {
                                        final shouldDelete =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title:
                                                const Text('Delete Technician'),
                                            content: Text(
                                              'Are you sure you want to delete ${technician.name}? This action cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (shouldDelete == true) {
                                          await provider.deleteTechnician(
                                              technician.sId!);
                                        }
                                      },
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withOpacity(0.15)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? Colors.green.withOpacity(0.5)
              : Colors.grey.withOpacity(0.5),
        ),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: active ? Colors.green : Colors.grey,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
