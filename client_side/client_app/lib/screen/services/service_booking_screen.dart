import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../login_screen/provider/user_provider.dart';
import 'provider/service_provider.dart';
import '../notifications_screen/notifications_provider.dart';
import '../../models/app_notification.dart';
import '../../models/technician.dart';

class ServiceBookingScreen extends StatefulWidget {
  final String category;
  final Technician? preSelectedTechnician;

  const ServiceBookingScreen({
    super.key,
    required this.category,
    this.preSelectedTechnician,
  });

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book ${widget.category}',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (v) => (v == null || v.trim().length < 7)
                      ? 'Enter a valid phone'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter address' : null,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Issue Description',
                    hintText: 'Describe the problem briefly',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now.add(const Duration(days: 1)),
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 60)),
                          );
                          if (picked != null)
                            setState(() => _preferredDate = picked);
                        },
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: Text(_preferredDate == null
                            ? 'Pick date'
                            : '${_preferredDate?.day ?? ''}/${_preferredDate?.month ?? ''}/${_preferredDate?.year ?? ''}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null)
                            setState(() => _preferredTime = picked);
                        },
                        icon: const Icon(Icons.schedule_rounded),
                        label: Text(_preferredTime == null
                            ? 'Pick time'
                            : _preferredTime?.format(context) ?? 'Pick time'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Request Booking'),
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_preferredDate == null || _preferredTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick preferred date and time')),
      );
      return;
    }
    final timeLabel = _preferredTime?.format(context) ?? '';

    try {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.getLoginUsr();
      final userId = user?.sId;

      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to continue')),
        );
        return;
      }

      final serviceProvider = context.read<ServiceProvider>();
      final (ok, msg) = await serviceProvider.createServiceRequest(
        category: widget.category,
        customerName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        preferredDate: _preferredDate ?? DateTime.now(),
        preferredTime: timeLabel,
        userId: userId,
      );

      if (!mounted) return; // Check if widget is still mounted

      // Show appropriate success/error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              ok ? 'Service booking request submitted successfully!' : msg),
          backgroundColor: ok ? Colors.green : Colors.red,
          duration: Duration(seconds: ok ? 3 : 5),
        ),
      );

      if (ok) {
        // Add an in-app notification entry safely
        try {
          context.read<NotificationsProvider>().add(
                AppNotification(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: 'Service booking submitted',
                  body: '${widget.category} • $timeLabel',
                  timestamp: DateTime.now(),
                  read: false,
                ),
              );
        } catch (e) {
          // Silently handle notification error - booking was still successful
          print('Notification error: $e');
        }

        // Add delay to allow SnackBar to be visible before navigating back
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      return;
    }
  }
}
