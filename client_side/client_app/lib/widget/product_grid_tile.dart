import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../models/product.dart';
import '../screen/product_favorite_screen/provider/favorite_provider.dart';
import '../utility/extensions.dart';
import '../utility/utility_extention.dart';
import '../utility/currency_helper.dart';
import '../utility/app_colors.dart';
import 'custom_network_image.dart';

class ProductGridTile extends StatelessWidget {
  final Product product;
  final int index;
  final bool isPriceOff;

  const ProductGridTile({
    super.key,
    required this.product,
    required this.index,
    required this.isPriceOff,
  });

  @override
  Widget build(BuildContext context) {
    double discountPercentage = context.dataProvider
        .calculateDiscountPercentage(
            product.price ?? 0, product.offerPrice ?? 0);
    return GridTile(
      header: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: discountPercentage != 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: AppRadius.xlRadius,
                  boxShadow: AppShadows.small,
                ),
                width: 80,
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  "OFF ${discountPercentage.toInt()} %",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Consumer<FavoriteProvider>(
              builder: (context, favoriteProvider, child) {
                return IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color:
                        favoriteProvider.checkIsItemFavorite(product.sId ?? '')
                            ? AppColors.error
                            : AppColors.textTertiary,
                  ),
                  onPressed: () {
                    context.favoriteProvider
                        .updateToFavoriteList(product.sId ?? '');
                  },
                );
              },
            ),
          ],
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: AppRadius.lgRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(
                minHeight: 60,
                maxHeight: 80,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: AppRadius.lgRadius.bottomLeft,
                  bottomRight: AppRadius.lgRadius.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: AppShadows.small,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        product.name ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product.offerPrice != 0
                                  ? CurrencyHelper.formatCurrencyCompact(
                                      product.offerPrice ?? 0)
                                  : CurrencyHelper.formatCurrencyCompact(
                                      product.price ?? 0),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (product.offerPrice != null &&
                            product.offerPrice != product.price)
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                CurrencyHelper.formatCurrencyCompact(
                                    product.price ?? 0),
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceContainer,
              AppColors.surfaceElevated,
            ],
          ),
          borderRadius: AppRadius.xlRadius,
          boxShadow: AppShadows.small,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: CustomNetworkImage(
                imageUrl: product.images!.isNotEmpty
                    ? product.images?.safeElementAt(0)?.url ?? ''
                    : '',
                fit: BoxFit.contain,
                scale: 1.0,
              ),
            );
          },
        ),
      ),
    );
  }
}
