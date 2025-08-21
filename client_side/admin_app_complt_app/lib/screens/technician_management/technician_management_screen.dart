import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../utility/constants.dart';
import 'components/technician_header.dart';
import 'components/technician_list_section.dart';
import 'components/add_technician_dialog.dart';
import '../service_requests/provider/technician_provider.dart';

class TechnicianManagementScreen extends StatefulWidget {
  const TechnicianManagementScreen({super.key});

  @override
  State<TechnicianManagementScreen> createState() =>
      _TechnicianManagementScreenState();
}

class _TechnicianManagementScreenState
    extends State<TechnicianManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechnicianProvider>().getAllTechnicians(showSnack: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const TechnicianHeader(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Technician Management',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const Gap(20),
                          SizedBox(
                            width: 280,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              value: 'All',
                              items: const [
                                DropdownMenuItem(
                                    value: 'All',
                                    child: Text('All technicians')),
                                DropdownMenuItem(
                                    value: 'true', child: Text('Active only')),
                                DropdownMenuItem(
                                    value: 'false',
                                    child: Text('Inactive only')),
                              ],
                              onChanged: (val) {
                                context
                                    .read<TechnicianProvider>()
                                    .filterByStatus(val);
                              },
                            ),
                          ),
                          const Gap(20),
                          SizedBox(
                            width: 260,
                            child: TextField(
                              onChanged: (value) => context
                                  .read<TechnicianProvider>()
                                  .filterTechnicians(value),
                              decoration: const InputDecoration(
                                hintText: 'Search by name/phone/skills',
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          const Gap(20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) =>
                                    const AddTechnicianDialog(),
                              );
                              if (result == true) {
                                if (mounted) {
                                  context
                                      .read<TechnicianProvider>()
                                      .getAllTechnicians();
                                }
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Technician'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const Gap(10),
                          IconButton(
                            onPressed: () {
                              context
                                  .read<TechnicianProvider>()
                                  .getAllTechnicians(showSnack: true);
                            },
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                      const Gap(defaultPadding),
                      const TechnicianListSection(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
