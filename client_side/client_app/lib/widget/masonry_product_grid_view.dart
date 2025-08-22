import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screen/product_details_screen/product_detail_screen.dart';
// import '../utility/animation/open_container_wrapper.dart';
import '../screen/product_cart_screen/provider/cart_provider.dart';
import 'premium_product_card.dart';

class MasonryProductGridView extends StatelessWidget {
  final List<Product> items;
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;
  final bool enableScrolling;
  final bool loading;

  const MasonryProductGridView({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.crossAxisCount = 0,
    this.enableScrolling = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Choose columns responsively when caller doesn't override.
    final width = MediaQuery.of(context).size.width;
    int autoColumns = (width / 260).floor().clamp(2, 8);
    if (width >= 1600) autoColumns = (width / 240).floor().clamp(2, 10);
    final columns = crossAxisCount > 0 ? crossAxisCount : autoColumns;

    if (loading) {
      // Show shimmer skeletons
      return MasonryGridView.count(
        padding: padding,
        physics: enableScrolling
            ? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics())
            : const NeverScrollableScrollPhysics(),
        shrinkWrap: !enableScrolling,
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: columns * 2,
        itemBuilder: (context, index) {
          return const _ShimmerProductCard();
        },
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return MasonryGridView.count(
      padding: padding,
      physics: enableScrolling
          ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !enableScrolling,
      crossAxisCount: columns,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        const double uniformHeight = 380;
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product),
              ),
            );
          },
          child: SizedBox(
            height: uniformHeight,
            child: PremiumProductCard(
              product: product,
              onAddToCart: () {
                context.read<CartProvider>().addProductToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to cart'),
                    duration: Duration(milliseconds: 900),
                  ),
                );
              },
              isGridView: true,
            ),
          ),
        );
      },
    );
  }
}

// Shimmer card must be top-level, not nested inside another class
class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            margin: const EdgeInsets.only(bottom: 12),
          ),
          // Title shimmer
          Container(
            height: 18,
            width: 120,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          // Category shimmer
          Container(
            height: 12,
            width: 60,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          // Price shimmer
          Container(
            height: 16,
            width: 80,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          // Button shimmer
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 16, top: 12),
            ),
          ),
        ],
      ),
    );
  }
}
