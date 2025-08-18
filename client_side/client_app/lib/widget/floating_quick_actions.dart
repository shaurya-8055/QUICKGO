import 'package:flutter/material.dart';

class FloatingQuickActions extends StatefulWidget {
  const FloatingQuickActions({super.key});

  @override
  State<FloatingQuickActions> createState() => _FloatingQuickActionsState();
}

class _FloatingQuickActionsState extends State<FloatingQuickActions>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<double> _animation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.75, // 3/4 rotation (270 degrees)
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
      _rotationController.forward();
    } else {
      _animationController.reverse();
      _rotationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.3),
            ),
          ),

        // Quick Action Buttons
        ..._buildQuickActionButtons(),

        // Main FAB
        Container(
          margin: const EdgeInsets.only(bottom: 16, right: 16),
          child: FloatingActionButton(
            heroTag: 'floatingQuickActionsFab',
            onPressed: _toggleMenu,
            backgroundColor: const Color(0xFF667eea),
            elevation: 8,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildQuickActionButtons() {
    final actions = [
      _QuickAction(
        icon: Icons.search,
        label: 'Search',
        color: const Color(0xFF4ECDC4),
        onTap: () {
          _toggleMenu();
          // Navigate to search
        },
      ),
      _QuickAction(
        icon: Icons.favorite_border,
        label: 'Wishlist',
        color: const Color(0xFFFF6B6B),
        onTap: () {
          _toggleMenu();
          // Navigate to wishlist
        },
      ),
      _QuickAction(
        icon: Icons.shopping_cart_outlined,
        label: 'Cart',
        color: const Color(0xFFFFBE0B),
        onTap: () {
          _toggleMenu();
          // Navigate to cart
        },
      ),
      _QuickAction(
        icon: Icons.support_agent,
        label: 'Help',
        color: const Color(0xFF8B5CF6),
        onTap: () {
          _toggleMenu();
          // Open help/support
        },
      ),
    ];

    return actions.asMap().entries.map((entry) {
      int index = entry.key;
      _QuickAction action = entry.value;

      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animationValue =
              Curves.elasticOut.transform(_animation.value).clamp(0.0, 1.0);
          final offset = (actions.length - index) * 70.0 * animationValue;

          return Container(
            margin: EdgeInsets.only(
              bottom: 80 + offset,
              right: 16,
            ),
            child: Transform.scale(
              scale: (animationValue as num).toDouble(),
              child: Opacity(
                opacity: (animationValue as num).toDouble(),
                child: _QuickActionButton(action: action),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionButton extends StatefulWidget {
  final _QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.action.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.action.label,
                    style: const TextStyle(
                      color: Color(0xFF2D3436),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Icon Button
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.action.color,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: widget.action.color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.action.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
