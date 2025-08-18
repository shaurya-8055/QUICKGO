import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screen/product_details_screen/product_detail_screen.dart';
import '../utility/animation/open_container_wrapper.dart';
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
          // Taller cards for portrait images
          childAspectRatio: 0.58,
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          Product product = items[index];
          return OpenContainerWrapper(
            nextScreen: ProductDetailScreen(product),
            transitionType: ContainerTransitionType.fadeThrough,
            borderRadius: 22,
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
