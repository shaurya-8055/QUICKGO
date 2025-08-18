import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utility/constants.dart';
import '../../utility/extensions.dart';
import 'components/service_request_header.dart';
import 'components/service_request_list_section.dart';

class ServiceRequestsScreen extends StatelessWidget {
  const ServiceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const ServiceRequestHeader(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              'All Service Requests',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          SizedBox(
                            width: 280,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              value: 'All',
                              items: const [
                                DropdownMenuItem(value: 'All', child: Text('All status')),
                                DropdownMenuItem(value: 'pending', child: Text('pending')),
                                DropdownMenuItem(value: 'approved', child: Text('approved')),
                                DropdownMenuItem(value: 'in-progress', child: Text('in-progress')),
                                DropdownMenuItem(value: 'completed', child: Text('completed')),
                                DropdownMenuItem(value: 'cancelled', child: Text('cancelled')),
                              ],
                              onChanged: (val) {
                                if (val == null || val == 'All') {
                                  context.dataProvider.getAllServiceRequests();
                                } else {
                                  context.dataProvider.getAllServiceRequests(status: val);
                                }
                              },
                            ),
                          ),
                          const Gap(20),
                          SizedBox(
                            width: 260,
                            child: TextField(
                              onChanged: (value) => context.dataProvider.filterServiceRequests(value),
                              decoration: const InputDecoration(
                                hintText: 'Search by name/phone/category',
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          const Gap(20),
                          IconButton(
                            onPressed: () {
                              context.dataProvider.getAllServiceRequests(showSnack: true);
                            },
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const Gap(defaultPadding),
                      const ServiceRequestListSection(),
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
