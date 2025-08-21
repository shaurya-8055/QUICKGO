import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screen/product_details_screen/product_detail_screen.dart';
import '../utility/animation/open_container_wrapper.dart';
import '../screen/product_cart_screen/provider/cart_provider.dart';
import 'optimized_product_card.dart';

/// High-Performance Product Grid optimized for 60fps smooth scrolling
/// Features: ListView.builder, pagination, lazy loading, viewport optimization
class OptimizedProductGrid extends StatefulWidget {
  final List<Product> products;
  final Function(int)? onLoadMore;
  final bool hasMoreData;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;

  const OptimizedProductGrid({
    super.key,
    required this.products,
    this.onLoadMore,
    this.hasMoreData = false,
    this.isLoading = false,
    this.padding = const EdgeInsets.all(16),
    this.crossAxisCount = 2,
  });

  @override
  State<OptimizedProductGrid> createState() => _OptimizedProductGridState();
}

class _OptimizedProductGridState extends State<OptimizedProductGrid>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMoreData || widget.isLoading) return;

    final double pixels = _scrollController.position.pixels;
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;

    // Trigger load more when near the end
    if (pixels >=
        maxScrollExtent - (MediaQuery.of(context).size.height * 0.5)) {
      widget.onLoadMore?.call(widget.products.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.products.isEmpty && !widget.isLoading) {
      return const Center(
        child: Text('No products found'),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        (screenWidth - 48) / widget.crossAxisCount; // Account for padding
    final cardHeight = cardWidth * 1.4; // Aspect ratio for product cards

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      // Calculate number of rows needed
      itemCount: _calculateItemCount(),
      cacheExtent: cardHeight * 3, // Cache 3 rows above and below viewport
      itemBuilder: (context, rowIndex) {
        return _buildRow(rowIndex, cardWidth, cardHeight);
      },
    );
  }

  int _calculateItemCount() {
    final productsCount = widget.products.length;
    final rowCount = (productsCount / widget.crossAxisCount).ceil();

    // Add 1 for loading indicator if needed
    return widget.isLoading ? rowCount + 1 : rowCount;
  }

  Widget _buildRow(int rowIndex, double cardWidth, double cardHeight) {
    final startIndex = rowIndex * widget.crossAxisCount;

    // Check if this is the loading row
    if (startIndex >= widget.products.length) {
      return _buildLoadingRow();
    }

    return Container(
      height: cardHeight,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.crossAxisCount, (columnIndex) {
          final productIndex = startIndex + columnIndex;

          if (productIndex >= widget.products.length) {
            return Expanded(child: Container()); // Empty space
          }

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: columnIndex < widget.crossAxisCount - 1 ? 12 : 0,
              ),
              child: _buildProductCard(productIndex),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final product = widget.products[index];

    return OpenContainerWrapper(
      nextScreen: ProductDetailScreen(product),
      borderRadius: 16,
      child: OptimizedProductCard(
        product: product,
        isVisible: true, // Simplified for now, always visible
        onAddToCart: () {
          context.read<CartProvider>().addProductToCart(product);
          _showAddToCartFeedback();
        },
      ),
    );
  }

  Widget _buildLoadingRow() {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading more products...'),
        ],
      ),
    );
  }

  void _showAddToCartFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart'),
        duration: Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
