import 'package:client_app/utility/extensions.dart';
import 'provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widget/masonry_product_grid_view.dart';
import '../home_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      context.favoriteProvider.loadFavoriteItems();
    });
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Home',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          ),
        ),
        title: Text(
          'Favorites',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                // High-contrast against current surface (light/dark adaptive)
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
        ),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              return MasonryProductGridView(
                items: favoriteProvider.favoriteProduct,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              );
            },
          )),
    );
  }
}
