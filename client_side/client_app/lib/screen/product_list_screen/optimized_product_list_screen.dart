import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../core/data/data_provider.dart';
import '../../core/providers/pagination_provider.dart';
import '../../widget/optimized_product_grid.dart';
import 'components/custom_app_bar.dart';
import 'components/enhanced_category_selector.dart';
import 'components/poster_section.dart';
import '../all_categories_screen.dart';
import '../../utility/animation/animated_button.dart';

/// High-Performance Product List Screen
/// Features: Pagination, smooth scrolling, efficient rebuilds, 60fps performance
class OptimizedProductListScreen extends StatefulWidget {
  const OptimizedProductListScreen({super.key, this.onBarVisibilityChanged});

  final ValueChanged<bool>? onBarVisibilityChanged;

  @override
  State<OptimizedProductListScreen> createState() =>
      _OptimizedProductListScreenState();
}

class _OptimizedProductListScreenState extends State<OptimizedProductListScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuredHeaderKey = GlobalKey();

  double _hideStartOffset = 0.0;
  bool _barVisible = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _computeHideStartOffset();
      _initializePagination();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _computeHideStartOffset() {
    final ctx = _featuredHeaderKey.currentContext;
    if (ctx == null) return;
    final render = ctx.findRenderObject();
    if (render is! RenderObject) return;
    final viewport = RenderAbstractViewport.of(render);
    final reveal = viewport.getOffsetToReveal(render, 0).offset;
    setState(() => _hideStartOffset = reveal + 24);
  }

  void _initializePagination() {
    final dataProvider = context.read<DataProvider>();
    final paginationProvider = context.read<PaginationProvider>();
    paginationProvider.initializeProducts(dataProvider.products);
  }

  void _toggleBar(bool show) {
    if (_barVisible == show) return;
    _barVisible = show;
    widget.onBarVisibilityChanged?.call(show);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final pos = _scrollController.position;
    final pixels = pos.pixels;

    // Before reaching featured products, keep bar visible
    if (pixels < _hideStartOffset) {
      _toggleBar(true);
      return;
    }

    // After featured section, react to scroll direction
    final dir = pos.userScrollDirection;
    if (dir == ScrollDirection.reverse) {
      _toggleBar(false);
    } else if (dir == ScrollDirection.forward) {
      _toggleBar(true);
    }
  }

  Future<void> _refreshProducts(BuildContext context) async {
    final paginationProvider = context.read<PaginationProvider>();
    final dataProvider = context.read<DataProvider>();

    // Refresh data from server
    await dataProvider.getAllProduct();

    // Reinitialize pagination with fresh data
    if (context.mounted) {
      paginationProvider.initializeProducts(dataProvider.products);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          color: Theme.of(context).primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Poster Section
              const SliverToBoxAdapter(
                child: PosterSection(),
              ),

              // Categories Section
              SliverToBoxAdapter(
                key: _featuredHeaderKey,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Top Categories",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                      ),
                      const Spacer(),
                      AnimatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const AllCategoriesScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 1.0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOutCubic,
                                  )),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 600),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Selector
              SliverToBoxAdapter(
                child: Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    return EnhancedCategorySelector(
                      categories: dataProvider.categories,
                    );
                  },
                ),
              ),

              // Products Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Row(
                    children: [
                      Text(
                        "Featured Products",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                      ),
                      const Spacer(),
                      _buildSortButton(),
                    ],
                  ),
                ),
              ),

              // Optimized Product Grid
              SliverFillRemaining(
                child: Consumer<PaginationProvider>(
                  builder: (context, paginationProvider, child) {
                    return OptimizedProductGrid(
                      products: paginationProvider.displayedProducts,
                      onLoadMore: (_) => paginationProvider.loadNextPage(),
                      hasMoreData: paginationProvider.hasMoreData,
                      isLoading: paginationProvider.isLoading,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort_rounded),
      onSelected: (value) {
        final paginationProvider = context.read<PaginationProvider>();
        switch (value) {
          case 'price_low':
            paginationProvider.sortByPrice(ascending: true);
            break;
          case 'price_high':
            paginationProvider.sortByPrice(ascending: false);
            break;
          case 'popular':
            paginationProvider.sortByPopularity();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'popular',
          child: Row(
            children: [
              Icon(Icons.trending_up_rounded),
              SizedBox(width: 8),
              Text('Popular'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'price_low',
          child: Row(
            children: [
              Icon(Icons.arrow_upward_rounded),
              SizedBox(width: 8),
              Text('Price: Low to High'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'price_high',
          child: Row(
            children: [
              Icon(Icons.arrow_downward_rounded),
              SizedBox(width: 8),
              Text('Price: High to Low'),
            ],
          ),
        ),
      ],
    );
  }
}
