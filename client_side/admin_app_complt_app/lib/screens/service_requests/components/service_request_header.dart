import 'package:flutter/material.dart';
import '../../../utility/constants.dart';

class ServiceRequestHeader extends StatelessWidget {
  const ServiceRequestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Service Requests",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: () {
              // Placeholder for export or bulk action, can be extended later
            },
            icon: const Icon(Icons.download),
            label: const Text('Export CSV'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          ),
        )
      ],
    );
  }
}
