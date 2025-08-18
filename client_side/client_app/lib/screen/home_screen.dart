import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import '../../../widget/page_wrapper.dart';
import 'scan_list/scan_list_screen.dart';
import 'product_cart_screen/provider/cart_provider.dart';
import 'product_cart_screen/cart_screen.dart';
import 'product_list_screen/product_list_screen.dart';
import 'profile_screen/profile_screen.dart';
import 'services/services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final List<Widget> screens = [
    ProductListScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen()
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int newIndex = 0;
  bool _showBottomBar = true;

  void _setBottomBarVisible(bool value) {
    if (_showBottomBar == value) return;
    setState(() => _showBottomBar = value);
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Scaffold(
        // Premium bottom bar with center FAB for quick actions
        bottomNavigationBar: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(
              position: slide,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _showBottomBar
              ? TopTierBottomBar(
                  key: const ValueKey('visible-bar'),
                  index: newIndex,
                  onChanged: (i) => setState(() => newIndex = i),
                )
              : const SizedBox.shrink(key: ValueKey('hidden-bar')),
        ),
        floatingActionButton: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInBack,
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: _showBottomBar
              ? QuickActionFab(
                  key: const ValueKey('visible-fab'),
                  onPressed: _openScanList,
                )
              : const SizedBox.shrink(key: ValueKey('hidden-fab')),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: PageTransitionSwitcher(
          duration: const Duration(seconds: 1),
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: _screenForIndex(newIndex),
        ),
      ),
    );
  }

  // Quick actions sheet available but unused; we open scan list directly for now.

  void _openScanList() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanListScreen()),
    );
  }

  Widget _screenForIndex(int i) {
    switch (i) {
      case 0:
        return ProductListScreen(onBarVisibilityChanged: _setBottomBarVisible);
      case 1:
        return const ServicesScreen();
      case 2:
        return const CartScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const ProductListScreen();
    }
  }
}

class TopTierBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const TopTierBottomBar(
      {super.key, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().myCartItems.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(0xFF111318).withOpacity(0.96)
        : Colors.white.withOpacity(0.95);
    final barShadow =
        isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.1);
    final accentShadow = isDark
        ? const Color(0xFF667eea).withOpacity(0.05)
        : const Color(0xFF667eea).withOpacity(0.1);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: barShadow,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
            BoxShadow(
              color: accentShadow,
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: SafeArea(
            top: false,
            child: MediaQuery(
              // Prevent large accessibility text from causing overflow inside the bar
              data: MediaQuery.of(context).copyWith(
                // Keep labels compact so the bar never overflows
                textScaleFactor:
                    MediaQuery.of(context).textScaleFactor.clamp(0.85, 1.0),
              ),
              child: BottomAppBar(
                color: surfaceColor,
                elevation: 0,
                // Give a touch more vertical room to avoid any debug overflows
                height: 64,
                shape: const AutomaticNotchedShape(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  StadiumBorder(),
                ),
                child: Container(
                  // Extra bottom padding to account for device insets and
                  // ensure content never clips.
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        selected: index == 0,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onChanged(0);
                        },
                      ),
                      _NavItem(
                        icon: Icons.home_repair_service_rounded,
                        label: 'Services',
                        selected: index == 1,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onChanged(1);
                        },
                      ),
                      const SizedBox(
                          width: 40), // Reduced space for smaller FAB notch
                      _NavItem(
                        customIcon: BadgeIcon(
                          icon: index == 2
                              ? Icons.shopping_bag
                              : Icons.shopping_bag_outlined,
                          filled: index == 2,
                          count: cartCount,
                        ),
                        label: 'Cart',
                        selected: index == 2,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onChanged(2);
                        },
                      ),
                      _NavItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        selected: index == 3,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onChanged(3);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final int count;
  const BadgeIcon(
      {super.key, required this.icon, this.filled = false, this.count = 0});

  @override
  Widget build(BuildContext context) {
    final showBadge = count > 0;
    final base =
        Icon(icon, color: filled ? const Color(0xFF667eea) : null, size: 18);
    if (!showBadge) return base;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        base,
        Positioned(
          right: -1,
          top: -1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFff6b6b), Color(0xFFee5a52)],
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFff6b6b).withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              count > 9 ? '9+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    this.icon,
    this.customIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeColor = Color(0xFF667eea);
    final inactiveColor =
        isDark ? const Color(0xFFB0B3B8) : const Color(0xFF636E72);
    final color = selected ? activeColor : inactiveColor;
    final selectedBgOpacity = isDark ? 0.16 : 0.10;
    final selectedBorderOpacity = isDark ? 0.30 : 0.24;
    final selectedGlowOpacity = isDark ? 0.42 : 0.26;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF667eea).withOpacity(selectedBgOpacity)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(
                  color: const Color(0xFF667eea)
                      .withOpacity(selectedBorderOpacity),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 1.2,
              width: selected ? 12 : 0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: selected ? 1.05 : 1.0,
              child: Container(
                height: 18,
                decoration: selected
                    ? BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea)
                                .withOpacity(selectedGlowOpacity),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      )
                    : null,
                child: customIcon ?? Icon(icon, color: color, size: 18),
              ),
            ),
            const SizedBox(height: 1),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: selected
                  ? Text(
                      label,
                      key: ValueKey(label),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.1,
                        height: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  : const SizedBox(height: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionFab extends StatefulWidget {
  final VoidCallback onPressed;
  const QuickActionFab({super.key, required this.onPressed});

  @override
  State<QuickActionFab> createState() => _QuickActionFabState();
}

class _QuickActionFabState extends State<QuickActionFab>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: FloatingActionButton.small(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape: const StadiumBorder(),
            heroTag: 'homeCenterFab',
            onPressed: widget.onPressed,
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
