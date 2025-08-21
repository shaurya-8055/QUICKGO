import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screen/product_favorite_screen/provider/favorite_provider.dart';
import '../utility/currency_helper.dart';
import 'custom_network_image.dart';

/// Optimized Product Card for smooth 60fps performance
/// Features: Minimal rebuilds, efficient animations, lazy image loading
class OptimizedProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final bool isVisible;

  const OptimizedProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.isVisible = true,
  });

  @override
  State<OptimizedProductCard> createState() => _OptimizedProductCardState();
}

class _OptimizedProductCardState extends State<OptimizedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final discountPercentage = _calculateDiscount(
      product.price ?? 0,
      product.offerPrice ?? 0,
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          _buildProductImage(product),
                          if (discountPercentage > 0)
                            _buildDiscountBadge(discountPercentage),
                          _buildFavoriteButton(),
                        ],
                      ),
                    ),
                    // Content Section with constrained height
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Product name with fixed height
                            SizedBox(
                              height: 32,
                              child: _buildProductName(product.name ?? ''),
                            ),
                            const SizedBox(height: 4),
                            // Price section with fixed height
                            SizedBox(
                              height: 20,
                              child: _buildPriceSection(product, discountPercentage),
                            ),
                            const Spacer(),
                            // Add to cart button with fixed height
                            SizedBox(
                              height: 28,
                              child: _buildAddToCartButton(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(Product product) {
    final imageUrl = product.images?.first.url ?? '';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: widget.isVisible && imageUrl.isNotEmpty
          ? CustomNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image_outlined,
                color: Colors.grey,
                size: 32,
              ),
            ),
    );
  }

  Widget _buildDiscountBadge(double discountPercentage) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${discountPercentage.toInt()}% OFF',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.grey[600],
            size: 20,
          ),
          onPressed: _toggleFavorite,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildProductName(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceSection(Product product, double discountPercentage) {
    return Row(
      children: [
        Text(
          CurrencyHelper.formatCurrency(
              product.offerPrice ?? product.price ?? 0),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (discountPercentage > 0) ...[
          const SizedBox(width: 6),
          Text(
            CurrencyHelper.formatCurrency(product.price ?? 0),
            style: TextStyle(
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      height: 28,
      child: ElevatedButton(
        onPressed: widget.onAddToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'Add to Cart',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  double _calculateDiscount(double originalPrice, double offerPrice) {
    if (originalPrice <= 0 || offerPrice <= 0 || offerPrice >= originalPrice) {
      return 0;
    }
    return ((originalPrice - offerPrice) / originalPrice) * 100;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    final favoriteProvider = context.read<FavoriteProvider>();
    favoriteProvider.updateToFavoriteList(widget.product.sId ?? '');
  }
}
