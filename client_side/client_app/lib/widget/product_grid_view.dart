// import 'package:client_app/widget/premium_product_card_refined.dart';
import 'package:flutter/material.dart';

// import 'package:animations/animations.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screen/product_details_screen/product_detail_screen.dart';
// import '../utility/animation/open_container_wrapper.dart';
import '../screen/product_cart_screen/provider/cart_provider.dart';
import 'premium_product_card.dart';

class ProductGridView extends StatelessWidget {
  const ProductGridView({
    super.key,
    required this.items,
  });

  final List<Product> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // Standardized cards for consistent alignment
          childAspectRatio: 0.85,
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          Product product = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product),
                ),
              );
            },
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
          );
        },
      ),
    );
  }
}
