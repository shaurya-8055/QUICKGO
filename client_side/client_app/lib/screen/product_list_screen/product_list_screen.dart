import '../../core/data/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'components/custom_app_bar.dart';
import '../../../../widget/masonry_product_grid_view.dart';
import 'components/enhanced_category_selector.dart';
import 'components/poster_section.dart';
import '../all_categories_screen.dart';
import '../../utility/animation/animated_button.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.onBarVisibilityChanged});

  final ValueChanged<bool>? onBarVisibilityChanged;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuredHeaderKey = GlobalKey();

  double _hideStartOffset = 0.0; // scroll offset where hiding behavior starts
  bool _barVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _computeHideStartOffset());
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
    // Scroll offset to reveal the featured header at the top
    final reveal = viewport.getOffsetToReveal(render, 0).offset;
    // Start hiding a bit after the header (e.g., +24 px)
    setState(() => _hideStartOffset = reveal + 24);
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
      // Scrolling down
      _toggleBar(false);
    } else if (dir == ScrollDirection.forward) {
      // Scrolling up
      _toggleBar(true);
    }
  }

  Future<void> _refreshProducts(BuildContext context) async {
    // Simulate refresh delay for better UX
    await Future.delayed(const Duration(milliseconds: 1200));
    // Refresh provider data
    if (context.mounted) {
      context.read<DataProvider>().getAllProduct();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [
                    Color(0xFF0E0F12),
                    Color(0xFF111318),
                  ]
                : const [
                    Color(0xFFF6F7FB),
                    Color(0xFFFFFFFF),
                  ],
            stops: const [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _refreshProducts(context),
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            strokeWidth: 2.5,
            displacement: 40,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Removed welcome header and divider to shift poster up

                  // Enhanced Poster Section
                  const PosterSection(),

                  // Categories Section with modern header
                  Container(
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
                            // Navigate to all categories screen with beautiful animation
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
                                    const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          scaleOnPress: 0.92,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF667eea).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "See All",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enhanced Category Selector
                  Consumer<DataProvider>(
                    builder: (context, dataProvider, child) {
                      return EnhancedCategorySelector(
                        categories: dataProvider.categories,
                      );
                    },
                  ),

                  // Products Section with modern header
                  Container(
                    key: _featuredHeaderKey,
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edge-to-edge Masonry Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Consumer<DataProvider>(
                      builder: (context, dataProvider, child) {
                        return MasonryProductGridView(
                          items: dataProvider.products,
                          padding: EdgeInsets.zero,
                          loading: dataProvider.loadingProducts,
                        );
                      },
                    ),
                  ),

                  // Bottom spacing
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton removed per request
    );
  }
}
