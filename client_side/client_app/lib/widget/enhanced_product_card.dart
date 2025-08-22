import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../screen/product_favorite_screen/provider/favorite_provider.dart';
import '../utility/currency_helper.dart';
import '../utility/app_colors.dart';
import 'dart:math' as math;
import 'dart:ui';

class EnhancedProductCard extends StatefulWidget {
  final Product product;
  const EnhancedProductCard({Key? key, required this.product}) : super(key: key);

  @override
  State<EnhancedProductCard> createState() => _EnhancedProductCardState();
}

class _EnhancedProductCardState extends State<EnhancedProductCard> with SingleTickerProviderStateMixin {
  // Animation controllers and variables
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0.97,
    upperBound: 1.0,
    value: 1.0,
  );
  late final AnimationController _favoriteController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    lowerBound: 0.85,
    upperBound: 1.0,
    value: 1.0,
  );
  late final AnimationController _cartController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: 0.85,
    upperBound: 1.0,
    value: 1.0,
  );
  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  late final Animation<double> _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(_scaleController);
  late final Animation<double> _favoriteAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(_favoriteController);
  late final Animation<double> _cartAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(_cartController);
  late final Animation<double> _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(_shimmerController);
  late final Animation<double> _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_rotationController);
  late final Animation<Offset> _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
    CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
  );

  bool isHovered = false;
  bool showQuickActions = false;

  @override
  void initState() {
    super.initState();
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _favoriteController.dispose();
    _cartController.dispose();
    _shimmerController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onCardTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    // If you want to handle tap, add a callback property to EnhancedProductCard.
  }

  void _onFavoriteTap() {
    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });

    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    favoriteProvider.updateToFavoriteList(widget.product.sId ?? '');
  }

  void _onAddToCartTap() {
    _cartController.forward().then((_) {
      _cartController.reverse();
    });
    // If you want to handle add to cart, add a callback property to EnhancedProductCard.
  }

  Widget _buildShimmerOverlay() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.xlRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                AppColors.glassPrimary,
                Colors.transparent,
              ],
              stops: [
                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscountBadge(double discountPercentage) {
    if (discountPercentage <= 0) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: AppRadius.mdRadius,
          boxShadow: AppShadows.small,
        ),
        child: Text(
          '-${discountPercentage.toStringAsFixed(0)}%',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _cartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cartAnimation.value,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShadows.medium,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _onAddToCartTap,
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _favoriteAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _favoriteAnimation.value,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _onFavoriteTap,
                        child: Consumer<FavoriteProvider>(
                          builder: (context, favoriteProvider, child) {
                            final isFavorite = favoriteProvider.favoriteProduct
                                .any((item) => item.sId == widget.product.sId);
                            return AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value,
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? const Color(0xFFFF6B6B)
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discountPercentage = widget.product.offerPrice != null
        ? ((widget.product.price! - widget.product.offerPrice!) /
                widget.product.price!) *
            100
        : 0.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _onCardTap,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  isHovered = true;
                  showQuickActions = true;
                });
                _scaleController.forward();
              },
              onExit: (_) {
                setState(() {
                  isHovered = false;
                  showQuickActions = false;
                });
                _scaleController.reverse();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.xlRadius,
                  gradient: AppColors.cardGradient,
                  boxShadow: isHovered ? AppShadows.premium : AppShadows.medium,
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.xlRadius,
                  child: Stack(
                    children: [
                      // Main content
                      // Main content: image and details, always square image
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Product Image Section (responsive square, no gap)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double size = constraints.maxWidth;
                              return SizedBox(
                                width: size,
                                height: size,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Product Image
                                      Positioned.fill(
                                        child: widget.product.images?.isNotEmpty == true
                                            ? Image.network(
                                                widget.product.images!.first.url ?? '',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.grey.shade200,
                                                          Colors.grey.shade100,
                                                        ],
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.image_not_supported_outlined,
                                                      size: 40,
                                                      color: Colors.grey.shade400,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.grey.shade200,
                                                      Colors.grey.shade100,
                                                    ],
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  size: 40,
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                      ),
                                      if (isHovered) _buildShimmerOverlay(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Product Details Section (no extra margin)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Product Name
                                Text(
                                  widget.product.name ?? 'Unknown Product',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D3436),
                                    letterSpacing: -0.2,
                                    height: 1.1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                // Category
                                if (widget.product.proCategoryId?.name != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF667eea).withOpacity(0.09),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      widget.product.proCategoryId!.name!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                // Price Section
                                Row(
                                  children: [
                                    Text(
                                      CurrencyHelper.formatCurrency(
                                          widget.product.offerPrice ??
                                              widget.product.price ??
                                              0),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2D3436),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    if (widget.product.offerPrice != null &&
                                        widget.product.price != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          CurrencyHelper.formatCurrency(
                                              widget.product.price!),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade500,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            widget.product.quantity != null &&
                                                    widget.product.quantity! > 0
                                                ? const Color(0xFF11998e).withOpacity(0.09)
                                                : const Color(0xFFFF6B6B).withOpacity(0.09),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            widget.product.quantity != null &&
                                                    widget.product.quantity! > 0
                                                ? Icons.check_circle_outline
                                                : Icons.remove_circle_outline,
                                            size: 11,
                                            color: widget.product.quantity != null && widget.product.quantity! > 0
                                                ? const Color(0xFF11998e)
                                                : const Color(0xFFFF6B6B),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            widget.product.quantity != null &&
                                                    widget.product.quantity! > 0
                                                ? 'In Stock'
                                                : 'Out of Stock',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: widget.product.quantity != null && widget.product.quantity! > 0
                                                  ? const Color(0xFF11998e)
                                                  : const Color(0xFFFF6B6B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Quick Actions (shown on hover)
                          if (showQuickActions) _buildQuickActionButtons(),
                        ],
                      ),

                      // Discount Badge
                      _buildDiscountBadge(discountPercentage),

                      // Stock Status
                      if (widget.product.quantity != null &&
                          widget.product.quantity! <= 5)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.product.quantity! == 0
                                  ? const Color(0xFFFF6B6B)
                                  : const Color(0xFFFFBE0B),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.product.quantity! == 0
                                          ? const Color(0xFFFF6B6B)
                                          : const Color(0xFFFFBE0B))
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.product.quantity! == 0
                                  ? 'Out of Stock'
                                  : 'Only ${widget.product.quantity} left',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
