import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../home_screen.dart';
import '../../utility/constants.dart';
import '../../utility/extensions.dart';

/// Standalone email OTP verification screen.
class OtpVerificationScreen extends StatefulWidget {
  final String? email;
  const OtpVerificationScreen({super.key, this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _codeCtrl = TextEditingController();
  final _box = GetStorage();
  bool _busy = false;

  String get _email =>
      widget.email ?? (_box.read(PENDING_OTP_EMAIL) as String? ?? '');

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_email.isEmpty) return;
    if (_codeCtrl.text.trim().length < 4) return; // basic check
    setState(() => _busy = true);
    final err = await context.userProvider
        .verifyEmailOtp(email: _email, code: _codeCtrl.text.trim());
    setState(() => _busy = false);
    if (err == null) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _resend() async {
    if (_email.isEmpty) return;
    setState(() => _busy = true);
    await context.userProvider.requestEmailOtp(email: _email);
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code sent to $_email',
                style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter 6-digit code'),
              maxLength: 6,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _busy ? null : _verify,
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('Verify'),
                ),
                const SizedBox(width: 12),
                TextButton(
                    onPressed: _busy ? null : _resend,
                    child: const Text('Resend code')),
              ],
            ),
            if (_busy) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(color: cs.primary),
            ]
          ],
        ),
      ),
    );
  }
}
