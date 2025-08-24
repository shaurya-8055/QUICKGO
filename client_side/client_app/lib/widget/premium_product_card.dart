import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../models/product.dart';
import '../screen/product_favorite_screen/provider/favorite_provider.dart';
import '../utility/currency_helper.dart';
import '../utility/app_colors.dart';
import 'custom_network_image.dart';

/// Premium Product Card with Top 1% App Design Standards
/// Features: Glassmorphism, Premium Gradients, Micro-animations, Haptic Feedback
class PremiumProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isGridView;

  const PremiumProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isGridView = true,
  }) : super(key: key);

  @override
  State<PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<PremiumProductCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late AnimationController _favoriteController;
  late AnimationController _shimmerController;

  late Animation<double> _hoverAnimation;
  late Animation<double> _tapAnimation;
  late Animation<double> _favoriteAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<Offset> _slideAnimation;

  bool isHovered = false;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    _favoriteController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onCardTap() {
    HapticFeedback.lightImpact();
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    widget.onTap?.call();
  }

  void _onFavoriteTap() {
    HapticFeedback.mediumImpact();
    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });

    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    favoriteProvider.updateToFavoriteList(widget.product.sId ?? '');
  }

  void _onAddToCartTap() {
    HapticFeedback.heavyImpact();
    widget.onAddToCart?.call();
  }

  double get discountPercentage {
    if (widget.product.offerPrice == null || widget.product.price == null)
      return 0;
    if (widget.product.offerPrice! >= widget.product.price!) return 0;
    return ((widget.product.price! - widget.product.offerPrice!) /
            widget.product.price!) *
        100;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Card backgrounds
    final LinearGradient cardGradNormal = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundElevated,
            ],
          )
        : AppColors.cardGradient;
    final LinearGradient cardGradHovered = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight.withOpacity(0.95),
              AppColors.backgroundElevated.withOpacity(0.85),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface.withOpacity(0.9),
              AppColors.surfaceElevated.withOpacity(0.8),
            ],
          );
    final Color borderBase = isDark ? AppColors.neutral40 : AppColors.border;
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverAnimation, _tapAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value * _tapAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap != null ? _onCardTap : null,
            onTapDown: widget.onTap != null
                ? (_) {
                    setState(() => isPressed = true);
                  }
                : null,
            onTapUp: widget.onTap != null
                ? (_) {
                    setState(() => isPressed = false);
                  }
                : null,
            onTapCancel: widget.onTap != null
                ? () {
                    setState(() => isPressed = false);
                  }
                : null,
            child: MouseRegion(
              onEnter: (_) {
                setState(() => isHovered = true);
                _hoverController.forward();
              },
              onExit: (_) {
                setState(() => isHovered = false);
                _hoverController.reverse();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.xlRadius,
                  boxShadow: isHovered ? AppShadows.premium : AppShadows.medium,
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.xlRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: isHovered ? 20 : 10,
                      sigmaY: isHovered ? 20 : 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isHovered ? cardGradHovered : cardGradNormal,
                        borderRadius: AppRadius.xlRadius,
                        border: Border.all(
                          color: isHovered
                              ? AppColors.secondary.withOpacity(0.3)
                              : borderBase.withOpacity(0.2),
                          width: isHovered ? 2 : 1,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          children: [
                            // Shimmer effect
                            if (isHovered) _buildShimmerOverlay(),

                            // Main content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image section with glassmorphism
                                Expanded(
                                  flex: widget.isGridView
                                      ? 4
                                      : 2, // balanced space for image on grid cards
                                  child: _buildImageSection(),
                                ),

                                // Content section
                                Expanded(
                                  flex: widget.isGridView
                                      ? 3
                                      : 3, // balanced space for content area
                                  child: _buildContentSection(),
                                ),
                              ],
                            ),

                            // Discount badge
                            if (discountPercentage > 0) _buildDiscountBadge(),

                            // Favorite button
                            _buildFavoriteButton(),

                            // Quick action overlay
                            if (isHovered && !widget.isGridView)
                              _buildQuickActions(),

                            // Always-available add-to-cart for grid cards
                            if (widget.isGridView) _buildGridAddButton(),
                          ],
                        ),
                      ),
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

  Widget _buildImageSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final LinearGradient imageBgGrad = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundElevated,
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceContainer,
              AppColors.surfaceElevated,
            ],
          );
    final Color emptyIconColor =
        isDark ? AppColors.neutral80 : AppColors.textTertiary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        gradient: imageBgGrad,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.small,
      ),
      child: AspectRatio(
        aspectRatio: 1 / 1, // square aspect for product images
        child: ClipRRect(
          borderRadius: AppRadius.lgRadius,
          child: widget.product.images?.isNotEmpty == true
              ? Hero(
                  tag: 'product_${widget.product.sId}',
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: CustomNetworkImage(
                      imageUrl: widget.product.images!.first.url ?? '',
                      fit: BoxFit
                          .contain, // keep image straight without cropping
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient.scale(0.1),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: emptyIconColor,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary =
        isDark ? AppColors.textInverse : AppColors.textPrimary;
    final Color textTertiary =
        isDark ? AppColors.neutral70 : AppColors.textTertiary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product name
          Text(
            widget.product.name ?? 'Product Name',
            style: TextStyle(
              fontSize: widget.isGridView ? 13.0 : 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Category
          if (widget.product.proCategoryId?.name != null) ...[
            const SizedBox(height: 3),
            Text(
              widget.product.proCategoryId!.name!,
              style: TextStyle(
                fontSize: 11.0,
                color: textTertiary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 3),

          // Price section
          _buildPriceSection(),

          // Stock status
          _buildStockStatus(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary =
        isDark ? AppColors.textInverse : AppColors.textPrimary;
    final Color textTertiary =
        isDark ? AppColors.neutral70 : AppColors.textTertiary;
    final hasOffer = widget.product.offerPrice != null &&
        widget.product.offerPrice! < widget.product.price!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  CurrencyHelper.formatCurrencyCompact(
                    hasOffer
                        ? widget.product.offerPrice!
                        : widget.product.price!,
                  ),
                  style: TextStyle(
                    fontSize: widget.isGridView ? 14.0 : 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
            if (hasOffer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  borderRadius: AppRadius.smRadius,
                ),
                child: Text(
                  '${discountPercentage.round()}% OFF',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
          ],
        ),
        if (hasOffer) ...[
          const SizedBox(height: 1),
          Text(
            CurrencyHelper.formatCurrencyCompact(widget.product.price!),
            style: TextStyle(
              fontSize: 10,
              decoration: TextDecoration.lineThrough,
              color: textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockStatus() {
    final inStock = (widget.product.quantity ?? 0) > 0;

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: inStock ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          inStock ? 'In Stock' : 'Out of Stock',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: inStock ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountBadge() {
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
          '-${discountPercentage.round()}%',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          final isFavorite =
              favoriteProvider.checkIsItemFavorite(widget.product.sId ?? '');

          return AnimatedBuilder(
            animation: _favoriteAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _favoriteAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.glassPrimary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.small,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _onFavoriteTap,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.error
                              : AppColors.textSecondary,
                          size: 18,
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

  Widget _buildQuickActions() {
    return SlideTransition(
      position: _slideAnimation,
      child: Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.lgRadius,
            boxShadow: AppShadows.medium,
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
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
  }

  Widget _buildGridAddButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4, right: 8),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: AppShadows.medium,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _onAddToCartTap,
            child: const Center(
              child: Icon(
                Icons.add_shopping_cart_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to scale gradients
extension GradientScale on LinearGradient {
  LinearGradient scale(double opacity) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors.map((color) => color.withOpacity(opacity)).toList(),
      stops: stops,
    );
  }
}
