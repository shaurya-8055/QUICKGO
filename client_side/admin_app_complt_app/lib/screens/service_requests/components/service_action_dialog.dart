import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../models/service_request.dart';
import '../../../models/technician.dart';
import '../../../utility/constants.dart';
import '../provider/service_provider.dart';
import '../provider/technician_provider.dart';

class ServiceActionDialog extends StatefulWidget {
  final ServiceRequest serviceRequest;
  final String action; // 'approve', 'in-progress', 'completed', 'cancel'

  const ServiceActionDialog({
    super.key,
    required this.serviceRequest,
    required this.action,
  });

  @override
  State<ServiceActionDialog> createState() => _ServiceActionDialogState();
}

class _ServiceActionDialogState extends State<ServiceActionDialog> {
  Technician? _selectedTechnician;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTechnicians() async {
    if (widget.action == 'approve' || widget.action == 'in-progress') {
      try {
        await context.read<TechnicianProvider>().getAllTechnicians();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load technicians: ${e.toString()}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  String get _dialogTitle {
    switch (widget.action) {
      case 'approve':
        return 'Approve Service Request';
      case 'in-progress':
        return 'Set to In Progress';
      case 'completed':
        return 'Mark as Completed';
      case 'cancel':
        return 'Cancel Service Request';
      default:
        return 'Update Service Request';
    }
  }

  String get _statusValue {
    switch (widget.action) {
      case 'approve':
        return 'approved';
      case 'in-progress':
        return 'in-progress';
      case 'completed':
        return 'completed';
      case 'cancel':
        return 'cancelled';
      default:
        return widget.serviceRequest.status ?? 'pending';
    }
  }

  Color get _actionColor {
    switch (widget.action) {
      case 'approve':
        return Colors.green;
      case 'in-progress':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancel':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get _actionIcon {
    switch (widget.action) {
      case 'approve':
        return Icons.check_circle;
      case 'in-progress':
        return Icons.play_circle_fill;
      case 'completed':
        return Icons.task_alt;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildTechnicianSection() {
    if (widget.action != 'approve' && widget.action != 'in-progress') {
      return const SizedBox.shrink();
    }

    final technicianProvider = context.watch<TechnicianProvider>();
    final technicians = technicianProvider.activeTechnicians;

    // Filter technicians by skills if possible
    final categorySkills =
        _getCategorySkills(widget.serviceRequest.category ?? '');
    final relevantTechnicians = categorySkills.isNotEmpty
        ? technicians
            .where((t) =>
                t.skills?.any((skill) => categorySkills.any(
                    (cs) => skill.toLowerCase().contains(cs.toLowerCase()))) ??
                false)
            .toList()
        : technicians;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(16),
        Text(
          'Assign Technician',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Gap(8),
        if (technicianProvider.loading)
          const Center(child: CircularProgressIndicator())
        else if (relevantTechnicians.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 20),
                const Gap(8),
                Expanded(
                  child: Text(
                    relevantTechnicians.isEmpty && technicians.isNotEmpty
                        ? 'No technicians found with relevant skills. Showing all active technicians.'
                        : 'No active technicians available.',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Technician>(
                value: _selectedTechnician,
                hint: const Text('Select a technician'),
                isExpanded: true,
                dropdownColor: secondaryColor,
                items: (relevantTechnicians.isNotEmpty
                        ? relevantTechnicians
                        : technicians)
                    .map((technician) {
                  // Ensure we have valid data for each technician
                  final name = technician.name ?? 'Unknown Technician';
                  final phone = technician.phone ?? 'No phone';
                  final skillsList = technician.skills?.isNotEmpty == true
                      ? technician.skills!.join(', ')
                      : 'No skills listed';

                  return DropdownMenuItem<Technician>(
                    value: technician,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$phone • Skills: $skillsList',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (technician) {
                  setState(() {
                    _selectedTechnician = technician;
                  });
                },
              ),
            ),
          ),
        if (_selectedTechnician != null) ...[
          const Gap(8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.green, size: 20),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected: ${_selectedTechnician!.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Phone: ${_selectedTechnician!.phone}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<String> _getCategorySkills(String category) {
    switch (category.toLowerCase()) {
      case 'ac repair':
      case 'air conditioner':
        return ['ac', 'air conditioner', 'hvac', 'cooling'];
      case 'mobile repair':
      case 'phone repair':
        return ['mobile', 'phone', 'smartphone', 'electronics'];
      case 'tv repair':
      case 'television':
        return ['tv', 'television', 'electronics', 'display'];
      case 'washing machine':
        return ['washing machine', 'appliance', 'laundry'];
      case 'refrigerator':
      case 'fridge':
        return ['refrigerator', 'fridge', 'appliance', 'cooling'];
      default:
        return ['general', 'electronics', 'appliance'];
    }
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(16),
        Text(
          'Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Gap(8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: widget.action == 'cancel'
                ? 'Reason for cancellation...'
                : 'Additional notes or instructions...',
            filled: true,
            fillColor: secondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Request Details',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Gap(8),
          _buildDetailRow(
              'Customer', widget.serviceRequest.customerName ?? '-'),
          _buildDetailRow('Phone', widget.serviceRequest.phone ?? '-'),
          _buildDetailRow('Category', widget.serviceRequest.category ?? '-'),
          _buildDetailRow('Address', widget.serviceRequest.address ?? '-'),
          if (widget.serviceRequest.description?.isNotEmpty == true)
            _buildDetailRow('Description', widget.serviceRequest.description!),
          _buildDetailRow(
            'Preferred Date',
            '${widget.serviceRequest.preferredDate ?? ''} ${widget.serviceRequest.preferredTime ?? ''}',
          ),
          _buildDetailRow(
              'Current Status', widget.serviceRequest.status ?? 'pending'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction() async {
    // Validate required fields for approve action
    if (widget.action == 'approve' && _selectedTechnician == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a technician to approve the request'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.action == 'cancel') {
      // For cancellation, show confirmation dialog first
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text(
            'Are you sure you want to cancel this service request? This action will permanently delete the request from the database.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, Keep Request'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Delete Request'),
            ),
          ],
        ),
      );

      if (shouldDelete != true) return;

      setState(() => _isLoading = true);

      try {
        final (success, message) = await context
            .read<ServiceProvider>()
            .deleteRequest(widget.serviceRequest.sId!);

        if (success) {
          if (mounted) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Service request cancelled and deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to cancel request: $message'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // For status updates
      setState(() => _isLoading = true);

      try {
        final (success, message) =
            await context.read<ServiceProvider>().updateStatus(
                  id: widget.serviceRequest.sId!,
                  status: _statusValue,
                  assigneeId: _selectedTechnician?.sId,
                  assigneeName: _selectedTechnician?.name,
                  assigneePhone: _selectedTechnician?.phone,
                  notes: _notesController.text.trim().isEmpty
                      ? null
                      : _notesController.text.trim(),
                );

        if (success) {
          if (mounted) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_getSuccessMessage()),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update request: $message'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  String _getSuccessMessage() {
    switch (widget.action) {
      case 'approve':
        return _selectedTechnician != null
            ? 'Request approved and assigned to ${_selectedTechnician!.name}'
            : 'Request approved successfully';
      case 'in-progress':
        return 'Status updated to "We are working on it"';
      case 'completed':
        return 'Request marked as completed by technician';
      default:
        return 'Request updated successfully';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

    return AlertDialog(
      title: Row(
        children: [
          Icon(_actionIcon, color: _actionColor),
          const Gap(8),
          Expanded(child: Text(_dialogTitle)),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: IntrinsicWidth(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceDetails(),
                _buildTechnicianSection(),
                _buildNotesSection(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: _actionColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.action == 'cancel'
                  ? 'Delete Request'
                  : 'Update Status'),
        ),
      ],
    );
  }
}
