import 'package:client_app/utility/extensions.dart';
import 'provider/product_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import '../../utility/currency_helper.dart';
import '../../utility/app_colors.dart';
import '../../utility/constants.dart';
import '../product_favorite_screen/provider/favorite_provider.dart';
// import '../../widget/custom_network_image.dart';
import '../../utility/image_loader.dart';
import '../../utility/offline_cache_helper.dart';
import '../../utility/accessibility_helper.dart';
import '../../widgets/animated_advanced_reviews_section.dart';
// import '../../widgets/enhanced_review_card.dart';
import '../../widgets/modern_review_carousel.dart';
import '../../widgets/fullscreen_image_viewer.dart';
import '../../models/review.dart';
import '../../data/dummy_review_data.dart';
import 'dart:async';

import 'dart:ui';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailScreen(this.product, {super.key});

  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _offlineProductData;
  bool _isOffline = false;
  // Carousel controller for reviews
  final PageController _reviewCarouselController =
      PageController(viewportFraction: 0.88);
  int _currentReviewPage = 0;
  List<Review> _carouselReviews = [];
  Timer? _carouselTimer;

  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load reviews for carousel (first 5 dummy reviews)
    _carouselReviews =
        DummyReviewData.getReviewsForProduct(widget.product?.sId ?? '')
            .take(5)
            .toList();
    _startCarouselAutoScroll();
    _loadOfflineProductIfNeeded();
  }

  Future<void> _loadOfflineProductIfNeeded() async {
    if (widget.product == null || widget.product!.sId == null) return;
    // Try to get cached product data
    final cached = await OfflineCacheHelper.getProduct(widget.product!.sId!);
    if (cached != null) {
      setState(() {
        _offlineProductData = cached;
        _isOffline = true;
      });
    }
  }

  void _startCarouselAutoScroll() {
    _carouselTimer?.cancel();
    if (_carouselReviews.length <= 1) return;
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_reviewCarouselController.hasClients) {
        _currentReviewPage = (_currentReviewPage + 1) % _carouselReviews.length;
        _reviewCarouselController.animateToPage(
          _currentReviewPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _reviewCarouselController.dispose();
    _animationController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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

  String? _getCurrentUserId() {
    final box = GetStorage();
    Map<String, dynamic>? userJson = box.read(USER_INFO_BOX);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }
    try {
      User? user = User.fromJson(userJson);
      return user.sId;
    } catch (e) {
      return null;
    }
  }

  String? _getCurrentUserToken() {
    final box = GetStorage();
    return box.read(AUTH_TOKEN_BOX) as String?;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final product = _isOffline && _offlineProductData != null
        ? Product.fromJson(_offlineProductData!)
        : widget.product;
    if (product == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Product not available",
            style: AccessibilityHelper.accessibleTextStyle(context,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildImageCarousel(product: product),
                _buildProductInfo(product: product),
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
          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
          borderRadius: AppRadius.mdRadius,
          boxShadow: AppShadows.medium,
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.mdRadius,
          child: InkWell(
            borderRadius: AppRadius.mdRadius,
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            borderRadius: AppRadius.mdRadius,
            boxShadow: AppShadows.medium,
            border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1)),
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
                      color: isFavorite
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            borderRadius: AppRadius.mdRadius,
            boxShadow: AppShadows.medium,
            border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1)),
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
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel({Product? product}) {
    final images = product?.images ?? [];

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
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (context, animation, _) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: FullscreenImageViewer(
                                            imageUrls: images
                                                .map((e) => e.url ?? '')
                                                .toList(),
                                            initialIndex: index,
                                            heroTagPrefix:
                                                'product_${product?.sId}',
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: 'product_${product?.sId}_$index',
                                  child: ImageLoader(
                                    imageUrl: images[index].url ?? '',
                                    fit: BoxFit.contain,
                                    semanticLabel: 'Product image ${index + 1}',
                                  ),
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

  Widget _buildProductInfo({Product? product}) {
    final colorScheme = Theme.of(context).colorScheme;
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
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
                      product?.name ?? 'Product Name',
                      style: AccessibilityHelper.accessibleTextStyle(context,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product?.proCategoryId?.name ?? 'Category',
                      style: AccessibilityHelper.accessibleTextStyle(context,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 20),
                    _buildPriceSection(product: product),
                    const SizedBox(height: 24),
                    // Stock status
                    _buildStockStatus(),
                    const SizedBox(height: 24),
                    // Variants if available
                    if (product?.proVariantId?.isNotEmpty == true)
                      _buildVariantSection(),
                    const SizedBox(height: 24),
                    // Description
                    _buildDescriptionSection(),
                    const SizedBox(height: 24),
                    // Features section
                    _buildFeaturesSection(),
                    const SizedBox(height: 32),
                    // Elegant section divider
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary.withOpacity(0.8),
                                    colorScheme.primary.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Customer Reviews',
                              style: AccessibilityHelper.accessibleTextStyle(
                                  context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      colorScheme.onSurface.withOpacity(0.7)),
                              // color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              // letterSpacing: 0.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Modern Review Carousel
                    if (_carouselReviews.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ModernReviewCarousel(reviews: _carouselReviews),
                      ),
                    // Show All Reviews Button
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.reviews),
                        label: const Text('Show All Reviews'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => Dialog(
                              insetPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: colorScheme.background,
                                child: AnimatedAdvancedReviewsSection(
                                  productId: product?.sId ?? '',
                                  userId: _getCurrentUserId(),
                                  canAddReview: _getCurrentUserId() != null &&
                                      _getCurrentUserToken() != null,
                                  onReviewAdded: () {
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Review added successfully!',
                                              style: AccessibilityHelper
                                                  .accessibleTextStyle(context,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: colorScheme
                                                          .onInverseSurface),
                                            ),
                                          ],
                                        ),
                                        backgroundColor:
                                            colorScheme.inverseSurface,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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

  Widget _buildPriceSection({Product? product}) {
    final hasOffer =
        product?.offerPrice != null && product?.offerPrice != product?.price;

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
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
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      CurrencyHelper.formatCurrencyCompact(
                        hasOffer == true
                            ? product!.offerPrice!
                            : product!.price!,
                      ),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    if (hasOffer == true) ...[
                      const SizedBox(width: 12),
                      Text(
                        CurrencyHelper.formatCurrencyCompact(product.price!),
                        style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (hasOffer == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                borderRadius: AppRadius.mdRadius,
              ),
              child: Text(
                'SAVE ${CurrencyHelper.formatCurrencyCompact(product.price! - product.offerPrice!)}',
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
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
                      color: isSelected
                          ? null
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                      ),
                      boxShadow: isSelected ? AppShadows.medium : null,
                    ),
                    child: Text(
                      variant,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
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
        Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedCrossFade(
          firstChild: Text(
            widget.product!.description ?? 'No description available.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontSize: 15,
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.product!.description ?? 'No description available.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
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
        Text(
          'Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppRadius.mdRadius,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature['subtitle'] as String,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                  border: Border.all(color: Theme.of(context).dividerColor),
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
