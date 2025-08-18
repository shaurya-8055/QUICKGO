import 'package:client_app/utility/extensions.dart';

import '../../models/brand.dart';
import '../../models/category.dart';
import '../../models/sub_category.dart';
import 'provider/product_by_category_provider.dart';
import '../../widget/custom_dropdown.dart';
import '../../widget/multi_select_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widget/horizondal_list.dart';
import '../../widget/masonry_product_grid_view.dart';

class ProductByCategoryScreen extends StatefulWidget {
  final Category selectedCategory;

  const ProductByCategoryScreen({super.key, required this.selectedCategory});

  @override
  State<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {
  bool _headerReady = false;
  bool _gridReady = false;

  @override
  void initState() {
    super.initState();
    // Initialize data
    Future.microtask(() {
      context.proByCProvider
          .filterInitialProductAndSubCategory(widget.selectedCategory);
      if (mounted) {
        setState(() => _headerReady = true);
        // Stagger grid entrance slightly after header
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) setState(() => _gridReady = true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              expandedHeight: 180,
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient header background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                    ),
                  ),
                  // Title centered with subtle fade/slide
                  Align(
                    alignment: Alignment(0, -0.2),
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      offset: _headerReady ? Offset.zero : const Offset(0, 0.3),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: _headerReady ? 1 : 0,
                        child: Text(
                          widget.selectedCategory.name ?? '',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Curved surface card holding subcategories + filters
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutBack,
                      offset: _headerReady ? Offset.zero : const Offset(0, 0.4),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, -4),
                            ),
                          ],
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Subcategories scroller
                            Consumer<ProductByCategoryProvider>(
                              builder: (context, proByCatProvider, child) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: HorizontalList(
                                    items: proByCatProvider.subCategories,
                                    itemToString: (SubCategory? val) =>
                                        val?.name ?? '',
                                    selected:
                                        proByCatProvider.mySelectedSubCategory,
                                    onSelect: (val) {
                                      if (val != null) {
                                        context.proByCProvider
                                            .filterProductBySubCategory(val);
                                      }
                                    },
                                    dense: true,
                                  ),
                                );
                              },
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _GlassCard(
                                    child: CustomDropdown<String>(
                                      hintText: 'Sort By Price',
                                      items: const [
                                        'Low To High',
                                        'High To Low'
                                      ],
                                      onChanged: (val) {
                                        if (val?.toLowerCase() ==
                                            'low to high') {
                                          context.proByCProvider
                                              .sortProducts(ascending: true);
                                        } else {
                                          context.proByCProvider
                                              .sortProducts(ascending: false);
                                        }
                                      },
                                      displayItem: (val) => val,
                                      dense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Consumer<ProductByCategoryProvider>(
                                    builder:
                                        (context, proByCatProvider, child) {
                                      return _GlassCard(
                                        child: MultiSelectDropDown<Brand>(
                                          hintText: 'Filter By Brands',
                                          items: proByCatProvider.brands,
                                          onSelectionChanged: (val) {
                                            proByCatProvider.selectedBrands =
                                                val;
                                            context.proByCProvider
                                                .filterProductByBrand();
                                            proByCatProvider.updateUI();
                                          },
                                          displayItem: (val) => val.name ?? '',
                                          selectedItems:
                                              proByCatProvider.selectedBrands,
                                          dense: true,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              sliver: SliverToBoxAdapter(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  opacity: _gridReady ? 1 : 0,
                  child: Consumer<ProductByCategoryProvider>(
                    builder: (context, proByCaProvider, child) {
                      return MasonryProductGridView(
                        items: proByCaProvider.filteredProduct,
                        padding: EdgeInsets.zero,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0x22171A20)
            : const Color(0x11FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
