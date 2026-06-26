import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main/main_screen.dart';
import '../../utility/constants.dart';
import '../../utility/snack_bar_helper.dart';
import '../../services/http_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = HttpService();
      final response = await service.addItem(
        endpointUrl: 'auth/login',
        itemData: {
          'identifier': _usernameController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (response.isOk) {
        await _processAuthResponse(response.body);
      } else {
        SnackBarHelper.showErrorSnackBar(
          response.body?['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Shared handling for any successful auth response (password, OTP, Google).
  // Enforces that only admin-role accounts can enter the dashboard.
  Future<void> _processAuthResponse(dynamic body) async {
    if (body == null || body['success'] != true) {
      SnackBarHelper.showErrorSnackBar(body?['message'] ?? 'Login failed');
      return;
    }
    final user = body['data']['user'];
    final accessToken = body['data']['accessToken'] ?? body['data']['token'];
    final refreshToken = body['data']['refreshToken'];

    if (user == null || user['role'] != 'admin') {
      SnackBarHelper.showErrorSnackBar('Admin access required');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      await prefs.setString('admin_access_token', accessToken);
    }
    if (refreshToken != null) {
      await prefs.setString('admin_refresh_token', refreshToken);
    }
    await prefs.setString('admin_user', user.toString());

    SnackBarHelper.showSuccessSnackBar('Welcome Admin!');
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    }
  }

  // Continue with Google, then verify the account is an admin.
  Future<void> _handleGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        clientId: GOOGLE_WEB_CLIENT_ID.isNotEmpty ? GOOGLE_WEB_CLIENT_ID : null,
        serverClientId:
            GOOGLE_WEB_CLIENT_ID.isNotEmpty ? GOOGLE_WEB_CLIENT_ID : null,
      );
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        SnackBarHelper.showErrorSnackBar('Google sign-in cancelled');
        return;
      }
      final gAuth = await account.authentication;
      final idToken = gAuth.idToken;
      if (idToken == null) {
        SnackBarHelper.showErrorSnackBar(
            'Could not obtain Google ID token. Check GOOGLE_WEB_CLIENT_ID.');
        return;
      }
      final service = HttpService();
      final response = await service
          .addItem(endpointUrl: 'auth/google', itemData: {'idToken': idToken});
      await _processAuthResponse(response.body);
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Google sign-in error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Email OTP: prompt for email, send code, prompt for code, verify.
  Future<void> _handleEmailOtp() async {
    final email = _usernameController.text.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!re.hasMatch(email)) {
      SnackBarHelper.showErrorSnackBar(
          'Enter your admin email in the field above first');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final service = HttpService();
      final sendRes = await service.addItem(
          endpointUrl: 'auth/email/request-otp', itemData: {'email': email});
      if (!(sendRes.isOk && sendRes.body['success'] == true)) {
        SnackBarHelper.showErrorSnackBar(
            sendRes.body?['message'] ?? 'Failed to send code');
        return;
      }
      SnackBarHelper.showSuccessSnackBar('Code sent to $email');

      final code = await _promptForCode();
      if (code == null || code.isEmpty) return;

      final verifyRes = await service.addItem(
          endpointUrl: 'auth/email/verify-otp',
          itemData: {'email': email, 'code': code});
      await _processAuthResponse(verifyRes.body);
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _promptForCode() async {
    final codeController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: secondaryColor,
        title: const Text('Enter email code',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(color: Colors.white, letterSpacing: 6),
          decoration: const InputDecoration(
            hintText: '6-digit code',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(codeController.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 64,
                  color: primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access the admin dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username/Email',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username/Email is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 12),

                // Email OTP login
                TextButton.icon(
                  onPressed: _isLoading ? null : _handleEmailOtp,
                  icon: const Icon(Icons.mark_email_read_outlined,
                      color: Colors.white70),
                  label: const Text('Login with email code',
                      style: TextStyle(color: Colors.white70)),
                ),

                const SizedBox(height: 4),
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR', style: TextStyle(color: Colors.white54)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 12),

                // Continue with Google
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogle,
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text('Continue with Google',
                      style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Footer
                const Text(
                  'QuickGo Admin Panel',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
