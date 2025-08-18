import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screen/product_details_screen/product_detail_screen.dart';
import '../utility/animation/open_container_wrapper.dart';
import '../screen/product_cart_screen/provider/cart_provider.dart';
import 'premium_product_card.dart';

class MasonryProductGridView extends StatelessWidget {
  final List<Product> items;
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;
  // When true, the grid becomes the primary scrollable (for pages like Favorites).
  // By default it's non-scrollable to embed inside outer scroll views.
  final bool enableScrolling;

  const MasonryProductGridView({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.crossAxisCount = 0, // 0 => auto (responsive)
    this.enableScrolling = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    // Choose columns responsively when caller doesn't override.
    final width = MediaQuery.of(context).size.width;
    // Auto columns: aim for ~260px cards; clamp between 2 and 8 columns.
    int autoColumns = (width / 260).floor().clamp(2, 8);
    // Slight boost for ultra-wide screens
    if (width >= 1600) autoColumns = (width / 240).floor().clamp(2, 10);
    final columns = crossAxisCount > 0 ? crossAxisCount : autoColumns;

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
        // Use a uniform taller height so all cards look the same size
        const double uniformHeight = 420;
        return OpenContainerWrapper(
          nextScreen: ProductDetailScreen(product),
          borderRadius: 22,
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
