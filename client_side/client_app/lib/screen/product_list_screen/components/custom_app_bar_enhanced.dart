import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../search_screen/advanced_search_screen.dart';
import '../../../widget/modern_filter_bottom_sheet.dart';
import '../../../core/data/data_provider.dart';
import '../../../utility/theme_provider.dart';
import '../../notifications_screen/notifications_screen.dart';
import '../../notifications_screen/notifications_provider.dart';
import '../../product_favorite_screen/favorite_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(80);

  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0F1115)
                : Colors.white.withOpacity(0.95)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16, vertical: 12),
          child: Row(
            children: [
              // Compact Search Bar - optimized for multiple elements
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF171A20)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdvancedSearchScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: Theme.of(context).hintColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isSmallScreen
                                    ? 'Search...'
                                    : 'Search products...',
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Filter Button
              _buildActionButton(
                context: context,
                icon: Icons.tune_rounded,
                hasGradient: true,
                gradientColors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2)
                ],
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ModernFilterBottomSheet(
                      onFiltersApplied: (filters) {
                        final dataProvider = context.read<DataProvider>();
                        dataProvider.applyFilters(
                          categories: filters['categories'],
                          brands: filters['brands'],
                          minPrice: filters['priceRange']?.start,
                          maxPrice: filters['priceRange']?.end,
                          sortBy: filters['sortBy'],
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Filters applied!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                },
                isSmall: isSmallScreen,
              ),

              const SizedBox(width: 8),

              // Theme Toggle Button
              _buildActionButton(
                context: context,
                icon: Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: () => context.read<ThemeProvider>().toggleTheme(),
                isSmall: isSmallScreen,
              ),

              const SizedBox(width: 8),

              // Favorites Button
              _buildActionButton(
                context: context,
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFE91E63),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoriteScreen(),
                    ),
                  );
                },
                isSmall: isSmallScreen,
              ),

              const SizedBox(width: 8),

              // Notifications Button with Badge
              _buildNotificationButton(context, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    bool hasGradient = false,
    List<Color>? gradientColors,
    bool isSmall = false,
  }) {
    final size = isSmall ? 40.0 : 44.0;
    final iconSize = isSmall ? 18.0 : 20.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: hasGradient && gradientColors != null
            ? LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasGradient
            ? null
            : (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF171A20)
                : const Color(0xFFF8F9FA)),
        borderRadius: BorderRadius.circular(14),
        border: hasGradient
            ? null
            : Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.12),
                width: 1,
              ),
        boxShadow: hasGradient
            ? [
                BoxShadow(
                  color: gradientColors![0].withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(
                      Theme.of(context).brightness == Brightness.dark
                          ? 0.3
                          : 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              color: hasGradient
                  ? Colors.white
                  : (iconColor ?? Theme.of(context).iconTheme.color),
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, bool isSmall) {
    final size = isSmall ? 40.0 : 44.0;
    final iconSize = isSmall ? 18.0 : 20.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF171A20)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const NotificationsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      ),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          },
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.notifications_rounded,
                  color: Theme.of(context).iconTheme.color,
                  size: iconSize,
                ),
              ),
              // Notification badge
              Positioned(
                top: isSmall ? 6 : 8,
                right: isSmall ? 6 : 8,
                child: Consumer<NotificationsProvider>(
                  builder: (context, np, _) {
                    final unread = np.unreadCount;
                    if (unread <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: EdgeInsets.all(isSmall ? 2 : 3),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: isSmall ? 16 : 18,
                        minHeight: isSmall ? 16 : 18,
                      ),
                      child: Text(
                        unread > 99 ? '99+' : unread.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 9 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
