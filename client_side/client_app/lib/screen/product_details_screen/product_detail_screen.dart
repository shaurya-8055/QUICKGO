import 'package:client_app/utility/extensions.dart';
import 'provider/product_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../models/product.dart';
import '../../utility/currency_helper.dart';
import '../../utility/app_colors.dart';
import '../product_favorite_screen/provider/favorite_provider.dart';
import '../../widget/custom_network_image.dart';
import 'dart:ui';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailScreen(this.product, {super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    _animationController.forward();
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Product not available",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildImageCarousel(),
                _buildProductInfo(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: AppRadius.mdRadius,
          boxShadow: AppShadows.medium,
          border: Border.all(color: AppColors.border.withOpacity(0.1)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.mdRadius,
          child: InkWell(
            borderRadius: AppRadius.mdRadius,
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.95),
            borderRadius: AppRadius.mdRadius,
            boxShadow: AppShadows.medium,
            border: Border.all(color: AppColors.border.withOpacity(0.1)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppRadius.mdRadius,
            child: Consumer<FavoriteProvider>(
              builder: (context, favoriteProvider, child) {
                final isFavorite = favoriteProvider
                    .checkIsItemFavorite(widget.product!.sId ?? '');
                return InkWell(
                  borderRadius: AppRadius.mdRadius,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    favoriteProvider
                        .updateToFavoriteList(widget.product!.sId ?? '');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorite ? AppColors.error : AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.95),
            borderRadius: AppRadius.mdRadius,
            boxShadow: AppShadows.medium,
            border: Border.all(color: AppColors.border.withOpacity(0.1)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppRadius.mdRadius,
            child: InkWell(
              borderRadius: AppRadius.mdRadius,
              onTap: () {
                // Share functionality
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.share_outlined,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.product!.images ?? [];

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: AppRadius.xxlRadius,
              boxShadow: AppShadows.premium,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.xxlRadius,
              child: Stack(
                children: [
                  // Main image carousel
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: images.isNotEmpty ? images.length : 1,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.surfaceContainer,
                              AppColors.surfaceElevated,
                            ],
                          ),
                        ),
                        child: images.isNotEmpty
                            ? Hero(
                                tag: 'product_${widget.product!.sId}_$index',
                                child: CustomNetworkImage(
                                  imageUrl: images[index].url ?? '',
                                  fit: BoxFit.contain,
                                ),
                              )
                            : const Icon(
                                Icons.image_outlined,
                                size: 80,
                                color: AppColors.textTertiary,
                              ),
                      );
                    },
                  ),

                  // Gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Page indicators
                  if (images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Discount badge
                  if (widget.product!.offerPrice != null &&
                      widget.product!.offerPrice != widget.product!.price)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: AppRadius.xlRadius,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '${(((widget.product!.price! - widget.product!.offerPrice!) / widget.product!.price!) * 100).round()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductInfo() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: AppShadows.large,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.smRadius,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name and category
                    Text(
                      widget.product!.name ?? 'Product Name',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product!.proCategoryId?.name ?? 'Category',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Price section
                    _buildPriceSection(),

                    const SizedBox(height: 24),

                    // Stock status
                    _buildStockStatus(),

                    const SizedBox(height: 24),

                    // Variants if available
                    if (widget.product!.proVariantId?.isNotEmpty == true)
                      _buildVariantSection(),

                    const SizedBox(height: 24),

                    // Description
                    _buildDescriptionSection(),

                    const SizedBox(height: 24),

                    // Features section
                    _buildFeaturesSection(),

                    const SizedBox(height: 100), // Space for bottom actions
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final hasOffer = widget.product!.offerPrice != null &&
        widget.product!.offerPrice != widget.product!.price;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient.scale(0.1),
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      CurrencyHelper.formatCurrencyCompact(
                        hasOffer
                            ? widget.product!.offerPrice!
                            : widget.product!.price!,
                      ),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    if (hasOffer) ...[
                      const SizedBox(width: 12),
                      Text(
                        CurrencyHelper.formatCurrencyCompact(
                            widget.product!.price!),
                        style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (hasOffer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                borderRadius: AppRadius.mdRadius,
              ),
              child: Text(
                'SAVE ${CurrencyHelper.formatCurrencyCompact(widget.product!.price! - widget.product!.offerPrice!)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockStatus() {
    final inStock =
        widget.product!.quantity != null && widget.product!.quantity! > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inStock ? const Color(0xFFE8F5E8) : const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inStock ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color:
                  inStock ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              inStock ? 'In Stock' : 'Out of Stock',
              style: TextStyle(
                color:
                    inStock ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (inStock)
            Icon(
              Icons.check_circle,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildVariantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available ${widget.product!.proVariantTypeId?.type ?? 'Options'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        Consumer<ProductDetailProvider>(
          builder: (context, provider, child) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: (widget.product!.proVariantId ?? []).map((variant) {
                final isSelected = provider.selectedVariant == variant;
                return GestureDetector(
                  onTap: () {
                    provider.selectedVariant = variant;
                    provider.updateUI();
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.surfaceContainer,
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(
                        color:
                            isSelected ? Colors.transparent : AppColors.border,
                      ),
                      boxShadow: isSelected ? AppShadows.medium : null,
                    ),
                    child: Text(
                      variant,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedCrossFade(
          firstChild: Text(
            widget.product!.description ?? 'No description available.',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.product!.description ?? 'No description available.',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              height: 1.6,
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? 'Show Less' : 'Read More',
            style: const TextStyle(
              color: Color(0xFF667eea),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Free Delivery',
        'subtitle': 'On orders above ₹1500'
      },
      {
        'icon': Icons.security_outlined,
        'title': '1 Year Warranty',
        'subtitle': 'Full coverage guarantee'
      },
      {
        'icon': Icons.replay_outlined,
        'title': 'Easy Returns',
        'subtitle': '30-day return policy'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppRadius.mdRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature['subtitle'] as String,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor:
                MediaQuery.of(context).textScaleFactor.clamp(0.85, 1.1),
          ),
          child: Row(
            children: [
              // Quantity selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Decrease quantity
                      },
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Increase quantity
                      },
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Add to cart button
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: widget.product!.quantity != 0
                        ? AppColors.primaryGradient
                        : null,
                    color: widget.product!.quantity == 0
                        ? AppColors.neutral90
                        : null,
                    borderRadius: AppRadius.lgRadius,
                    boxShadow: widget.product!.quantity != 0
                        ? AppShadows.medium
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: AppRadius.lgRadius,
                    child: InkWell(
                      borderRadius: AppRadius.lgRadius,
                      onTap: widget.product!.quantity != 0
                          ? () {
                              HapticFeedback.mediumImpact();
                              context.proDetailProvider
                                  .addToCart(widget.product!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Added to cart successfully!'),
                                  backgroundColor: const Color(0xFF4CAF50),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: widget.product!.quantity != 0
                                  ? AppColors.textOnPrimary
                                  : AppColors.textTertiary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.product!.quantity != 0
                                  ? 'Add to Cart'
                                  : 'Out of Stock',
                              style: TextStyle(
                                color: widget.product!.quantity != 0
                                    ? AppColors.textOnPrimary
                                    : AppColors.textTertiary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
