import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../models/product.dart';
import '../screen/product_favorite_screen/provider/favorite_provider.dart';
import '../utility/currency_helper.dart';
import '../utility/app_colors.dart';

class EnhancedProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const EnhancedProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  }) : super(key: key);

  @override
  State<EnhancedProductCard> createState() => _EnhancedProductCardState();
}

class _EnhancedProductCardState extends State<EnhancedProductCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _favoriteController;
  late AnimationController _cartController;
  late AnimationController _shimmerController;
  late AnimationController _rotationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _favoriteAnimation;
  late Animation<double> _cartAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  bool isHovered = false;
  bool showQuickActions = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cartController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));

    _cartAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _cartController,
      curve: Curves.bounceOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

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
    widget.onTap?.call();
  }

  void _onFavoriteTap() {
    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });

    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    favoriteProvider.updateToFavoriteList(widget.product.sId ?? '');
  }

  void _onAddToCartTap() {
    _cartController.forward().then((_) {
      _cartController.reverse();
    });
    widget.onAddToCart?.call();
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
                        borderRadius: AppRadius.lgRadius,
                        boxShadow: AppShadows.small,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: AppRadius.lgRadius,
                        child: InkWell(
                          borderRadius: AppRadius.lgRadius,
                          onTap: _onAddToCartTap,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: AppColors.textOnPrimary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    color: AppColors.textOnPrimary,
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
                      color: AppColors.surface,
                      borderRadius: AppRadius.lgRadius,
                      border: Border.all(
                        color: AppColors.border,
                      ),
                      boxShadow: AppShadows.small,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: AppRadius.lgRadius,
                      child: InkWell(
                        borderRadius: AppRadius.lgRadius,
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
                                        ? AppColors.error
                                        : AppColors.textSecondary,
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
                  gradient: isHovered
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.surface,
                            AppColors.surfaceElevated,
                          ],
                        )
                      : AppColors.cardGradient,
                  boxShadow: isHovered ? AppShadows.premium : AppShadows.medium,
                  border: Border.all(
                    color: isHovered
                        ? AppColors.secondary.withOpacity(0.3)
                        : AppColors.border.withOpacity(0.2),
                    width: isHovered ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.xlRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: isHovered ? 20 : 10,
                      sigmaY: isHovered ? 20 : 10,
                    ),
                    child: Stack(
                      children: [
                        // Main content
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image Section
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.surfaceContainer,
                                      AppColors.surface,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Product Image
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          topRight: Radius.circular(24),
                                        ),
                                        child: widget.product.images
                                                    ?.isNotEmpty ==
                                                true
                                            ? Image.network(
                                                widget.product.images!.first
                                                        .url ??
                                                    '',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppColors
                                                              .surfaceContainer,
                                                          AppColors.surface,
                                                        ],
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      size: 40,
                                                      color: AppColors
                                                          .textTertiary,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors
                                                          .surfaceContainer,
                                                      AppColors.surface,
                                                    ],
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  size: 40,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                      ),
                                    ),

                                    // Shimmer overlay when hovered
                                    if (isHovered) _buildShimmerOverlay(),
                                  ],
                                ),
                              ),
                            ),

                            // Product Details Section
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 140, // Fixed height to prevent overflow
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Product Name
                                    Flexible(
                                      child: Text(
                                        widget.product.name ??
                                            'Unknown Product',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.2,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Category
                                    if (widget.product.proCategoryId?.name !=
                                        null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary
                                              .withOpacity(0.1),
                                          borderRadius: AppRadius.smRadius,
                                        ),
                                        child: Text(
                                          widget.product.proCategoryId!.name!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ),

                                    const Spacer(),

                                    // Price Section
                                    Row(
                                      children: [
                                        // Current Price
                                        Expanded(
                                          flex: 3,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              CurrencyHelper.formatCurrency(
                                                  widget.product.offerPrice ??
                                                      widget.product.price ??
                                                      0),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textPrimary,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Original Price (if discounted)
                                        if (widget.product.offerPrice != null &&
                                            widget.product.price != null)
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  CurrencyHelper.formatCurrency(
                                                      widget.product.price!),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColors.textTertiary,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                        const SizedBox(width: 8),

                                        // Stock indicator
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: widget.product.quantity !=
                                                          null &&
                                                      widget.product.quantity! >
                                                          0
                                                  ? AppColors.success
                                                      .withOpacity(0.1)
                                                  : AppColors.error
                                                      .withOpacity(0.1),
                                              borderRadius: AppRadius.smRadius,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  widget.product.quantity !=
                                                              null &&
                                                          widget.product
                                                                  .quantity! >
                                                              0
                                                      ? Icons
                                                          .check_circle_outline
                                                      : Icons
                                                          .remove_circle_outline,
                                                  size: 12,
                                                  color: widget.product
                                                                  .quantity !=
                                                              null &&
                                                          widget.product
                                                                  .quantity! >
                                                              0
                                                      ? AppColors.success
                                                      : AppColors.error,
                                                ),
                                                const SizedBox(width: 2),
                                                Flexible(
                                                  child: Text(
                                                    widget.product.quantity !=
                                                                null &&
                                                            widget.product
                                                                    .quantity! >
                                                                0
                                                        ? 'In Stock'
                                                        : 'Out of Stock',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: widget.product
                                                                      .quantity !=
                                                                  null &&
                                                              widget.product
                                                                      .quantity! >
                                                                  0
                                                          ? AppColors.success
                                                          : AppColors.error,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Quick Actions (shown on hover)
                            if (showQuickActions) _buildQuickActionButtons(),
                          ],
                        ),

                        // Discount Badge
                        _buildDiscountBadge(discountPercentage),

                        // Stock Status Badge
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
                                    ? AppColors.error
                                    : AppColors.warning,
                                borderRadius: AppRadius.mdRadius,
                                boxShadow: AppShadows.small,
                              ),
                              child: Text(
                                widget.product.quantity! == 0
                                    ? 'Out of Stock'
                                    : 'Only ${widget.product.quantity} left',
                                style: TextStyle(
                                  color: AppColors.textOnPrimary,
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
          ),
        );
      },
    );
  }
}
