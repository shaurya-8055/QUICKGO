import '../../product_by_category_screen/product_by_category_screen.dart';
import '../../../utility/animation/open_container_wrapper.dart';
import 'package:flutter/material.dart';
import '../../../models/category.dart';

class EnhancedCategorySelector extends StatefulWidget {
  final List<Category> categories;

  const EnhancedCategorySelector({
    super.key,
    required this.categories,
  });

  @override
  State<EnhancedCategorySelector> createState() =>
      _EnhancedCategorySelectorState();
}

class _EnhancedCategorySelectorState extends State<EnhancedCategorySelector>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  List<AnimationController> _itemControllers = [];
  List<Animation<double>> _itemAnimations = [];
  int _previousCategoryCount = 0;

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _updateAnimationControllers();
  }

  @override
  void didUpdateWidget(EnhancedCategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories.length != widget.categories.length) {
      _updateAnimationControllers();
    }
  }

  void _updateAnimationControllers() {
    // Dispose old controllers
    for (var controller in _itemControllers) {
      controller.dispose();
    }

    // Create new controllers for current categories
    _itemControllers = List.generate(
      widget.categories.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _itemAnimations = _itemControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    // Update stagger controller duration
    _staggerController.duration =
        Duration(milliseconds: widget.categories.length * 100 + 500);

    if (widget.categories.isNotEmpty &&
        _previousCategoryCount != widget.categories.length) {
      _startStaggeredAnimation();
      _previousCategoryCount = widget.categories.length;
    }
  }

  void _startStaggeredAnimation() async {
    if (_itemControllers.isEmpty) return;

    // Ensure all items appear within ~1 second total
    final count = _itemControllers.length;
    const totalMs = 1000; // 1 second cap
    // Compute per-item delay; clamp to reasonable bounds
    final perDelayMs =
        (totalMs / (count == 0 ? 1 : count)).clamp(10, 200).toInt();

    // Start first item immediately for snappy feel
    if (mounted) {
      _itemControllers.first.forward();
    }

    for (int i = 1; i < count; i++) {
      final delay = Duration(milliseconds: i * perDelayMs);
      Future.delayed(delay, () {
        if (!mounted) return;
        if (i < _itemControllers.length) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if no categories or animations not ready
    if (widget.categories.isEmpty ||
        _itemAnimations.length != widget.categories.length) {
      return Container(
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Compute size to fit N cards based on screen width (responsive)
    final screenW = MediaQuery.of(context).size.width;
    final bool isTablet = screenW >= 720;
    // Choose visible count by breakpoint so it feels natural across devices
    final int visibleCount = screenW < 340
        ? 4 // Reduced for better spacing on small screens
        : (screenW < 420 ? 5 : (screenW < 600 ? 6 : (screenW < 900 ? 7 : 8)));
    const listHPadding = 20.0; // Increased horizontal padding
    final spacing = isTablet ? 16.0 : 12.0; // More spacing between cards
    final cardW =
        ((screenW - (listHPadding * 2) - spacing * (visibleCount - 1)) /
                visibleCount)
            .clamp(75.0, 130.0); // Slightly larger cards
    // Height = image (flex) + label. Our label is ~2 lines max; budget ~28px.
    final cardH = cardW + 32; // More room for better proportions

    return Container(
      height: cardH + 20, // More vertical padding
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: listHPadding),
        physics: const BouncingScrollPhysics(), // Enhanced scroll physics
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];

          // Safety check to prevent range errors
          if (index >= _itemAnimations.length ||
              index >= _itemControllers.length) {
            return const SizedBox.shrink();
          }

          return AnimatedBuilder(
            animation: _itemAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _itemAnimations[index].value,
                child: Transform.translate(
                  offset: Offset(
                      0,
                      30 *
                          (1 - _itemAnimations[index].value)), // Reduced bounce
                  child: Opacity(
                    opacity: (_itemAnimations[index].value.clamp(0.0, 1.0))
                        .toDouble(),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
                      child: OpenContainerWrapper(
                        nextScreen: ProductByCategoryScreen(
                            selectedCategory: widget.categories[index]),
                        child: PremiumCategoryCard(
                          category: category,
                          index: index,
                          width: cardW,
                          height: cardH,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// A premium portrait card with enhanced styling and shadows
class PremiumCategoryCard extends StatefulWidget {
  final Category category;
  final int index;
  final double width;
  final double height;

  const PremiumCategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.width,
    required this.height,
  });

  @override
  State<PremiumCategoryCard> createState() => _PremiumCategoryCardState();
}

class _PremiumCategoryCardState extends State<PremiumCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  // Premium gradient colors for each category
  List<Color> _getCategoryGradient(int index) {
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)], // Purple-Blue
      [const Color(0xFFf093fb), const Color(0xFFf5576c)], // Pink-Red
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue-Cyan
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Green-Teal
      [const Color(0xFFfa709a), const Color(0xFFfee140)], // Pink-Yellow
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)], // Mint-Pink
      [const Color(0xFFffecd2), const Color(0xFFfcb69f)], // Peach-Orange
      [const Color(0xFFd299c2), const Color(0xFFfef9d7)], // Purple-Cream
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag =
        'category_${widget.category.sId ?? widget.category.name ?? 'idx_${widget.index}'}';
    final isSelected = widget.category.isSelected;
    final gradientColors = _getCategoryGradient(widget.index);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? gradientColors
                    : [
                        theme.brightness == Brightness.dark
                            ? const Color(0xFF1A1D23)
                            : Colors.white,
                        theme.brightness == Brightness.dark
                            ? const Color(0xFF1F2329)
                            : const Color(0xFFF8F9FA),
                      ],
              ),
              border: isSelected
                  ? null
                  : Border.all(
                      color: theme.dividerColor.withOpacity(0.12),
                      width: 1,
                    ),
              boxShadow: [
                if (isSelected) ...[
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 2,
                  ),
                ] else ...[
                  BoxShadow(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Hero(
                    tag: tag,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (widget.category.image != null &&
                                widget.category.image!.isNotEmpty)
                            ? Image.network(
                                widget.category.image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: gradientColors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: CircularProgressIndicator(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.8),
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stack) {
                                  // Fallback with category-specific icons and colors
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: gradientColors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      _getCategoryIcon(widget.category.name),
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  _getCategoryIcon(widget.category.name),
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  child: Text(
                    _getShortCategoryName(widget.category.name ?? ''),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withOpacity(0.9),
                      fontSize: (widget.width / 7.5).clamp(12.0, 14.0),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Shorten category names for better display
  String _getShortCategoryName(String name) {
    final shortNames = {
      'Stationary': 'Stationery',
      'Electronics': 'Electronics',
      'School Bags': 'Bags',
      'Lunch Box': 'Lunch Box',
      'Books': 'Books',
      'Toys': 'Toys',
      'Clothing': 'Clothes',
      'Appliances': 'Appliances',
      'Grocery': 'Grocery',
    };
    return shortNames[name] ?? name;
  }

  // Get appropriate icon for each category
  IconData _getCategoryIcon(String? categoryName) {
    final String name = categoryName?.toLowerCase() ?? '';

    if (name.contains('stationary') || name.contains('stationery')) {
      return Icons.edit_rounded;
    } else if (name.contains('books')) {
      return Icons.menu_book_rounded;
    } else if (name.contains('bag') || name.contains('school bag')) {
      return Icons.school_rounded;
    } else if (name.contains('bottle')) {
      return Icons.sports_bar_rounded;
    } else if (name.contains('lunch') || name.contains('box')) {
      return Icons.lunch_dining_rounded;
    } else if (name.contains('pencil')) {
      return Icons.edit_rounded;
    } else if (name.contains('gift')) {
      return Icons.card_giftcard_rounded;
    } else if (name.contains('sport')) {
      return Icons.sports_soccer_rounded;
    } else if (name.contains('electronics')) {
      return Icons.devices_rounded;
    } else if (name.contains('toy')) {
      return Icons.toys_rounded;
    } else if (name.contains('clothing') || name.contains('clothes')) {
      return Icons.checkroom_rounded;
    } else if (name.contains('appliances')) {
      return Icons.kitchen_rounded;
    } else if (name.contains('grocery')) {
      return Icons.shopping_basket_rounded;
    } else {
      return Icons.category_rounded;
    }
  }
}
