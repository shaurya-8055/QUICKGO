import '../login_screen/login_screen.dart';
import '../my_address_screen/my_address_screen.dart';
import '../../utility/animation/open_container_wrapper.dart';
import '../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../my_order_screen/my_order_screen.dart';
import '../product_favorite_screen/favorite_screen.dart';
import '../notifications_screen/notifications_screen.dart';
import '../services/my_service_requests_screen.dart';
import '../../utility/theme_provider.dart';
import 'package:provider/provider.dart';
import '../home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = context.userProvider.getLoginUsr();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.brightness == Brightness.dark
                      ? [const Color(0xFF1B1F2A), const Color(0xFF22293A)]
                      : [const Color(0xFF667eea), const Color(0xFF764ba2)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                              (route) => false,
                            ),
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            tooltip: 'Back to Home',
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'My Account',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_rounded,
                            color: Colors.white),
                        tooltip: 'Notifications',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Avatar card (overlapping)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border:
                      Border.all(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [cs.primary, cs.primary.withOpacity(0.6)]),
                      ),
                      child: const CircleAvatar(
                        radius: 36,
                        backgroundImage:
                            AssetImage('assets/images/profile_pic.png'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.createdAt != null
                                ? 'Member since ${DateTime.tryParse(user!.createdAt!)?.year ?? ''}'
                                : 'Welcome! Explore our latest products',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.edit_rounded, color: cs.primary),
                      tooltip: 'Edit profile',
                    )
                  ],
                ),
              ),
            ),

            // Quick actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Row(
                  children: [
                    _QuickAction(
                      color: cs.primary,
                      icon: Icons.receipt_long_rounded,
                      label: 'Orders',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyOrderScreen()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      color: const Color(0xFF38ef7d),
                      icon: Icons.location_on_rounded,
                      label: 'Addresses',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyAddressPage()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      color: const Color(0xFFff8a65),
                      icon: Icons.favorite_rounded,
                      label: 'Favorites',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FavoriteScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.home_repair_service_rounded,
                    title: 'My Service Requests',
                    subtitle: 'Track technician bookings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyServiceRequestsScreen()),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    subtitle: 'View all notifications',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    subtitle: 'Toggle theme',
                    trailing: Switch(
                      value: theme.brightness == Brightness.dark,
                      onChanged: (_) =>
                          context.read<ThemeProvider>().toggleTheme(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Logout button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    context.userProvider.logOutUser();
                    Get.offAll(const LoginScreen());
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.color,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: OpenContainerWrapper(
        nextScreen: const SizedBox.shrink(),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 84,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile(
      {required this.icon,
      required this.title,
      this.subtitle,
      this.trailing,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: cs.primary.withOpacity(0.1),
          foregroundColor: cs.primary,
          child: Icon(icon),
        ),
        title: Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: theme.textTheme.bodySmall)
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
