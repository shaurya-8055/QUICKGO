import 'package:client_app/utility/extensions.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../core/data/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../../product_details_screen/product_detail_screen.dart';

class PosterSection extends StatefulWidget {
  const PosterSection({super.key});

  @override
  State<PosterSection> createState() => _PosterSectionState();
}

class _PosterSectionState extends State<PosterSection>
    with TickerProviderStateMixin {
  PageController _pageController = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      if (dataProvider.posters.isNotEmpty) {
        _currentPage = (_currentPage + 1) % dataProvider.posters.length;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutQuart,
          );
        }
        // Preload the next image to ensure smooth transition
        _precachePoster(_currentPage + 1);
      }
    });
  }

  void _precachePoster(int index) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.posters.isEmpty) return;
    final safeIndex = index % dataProvider.posters.length;
    final url = dataProvider.posters[safeIndex].imageUrl;
    if (url == null || url.isEmpty) return;
    precacheImage(NetworkImage(url), context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      if (dataProvider.posters.isNotEmpty) {
        _precachePoster(0);
        if (dataProvider.posters.length > 1) {
          _precachePoster(1);
        }
      }
      _imagesPrecached = true;
    }
  }

  // Modern gradient color combinations for posters
  List<Color> _getPosterGradient(int index) {
    final gradients = [
      // Sunset Orange to Pink
      [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
      // Purple to Blue
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      // Green to Teal
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      // Orange to Red
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      // Blue to Purple
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      // Pink to Orange
      [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          280, // Slightly shortened to shift section up and reduce footprint
      child: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.posters.isEmpty) {
            return Center(
              child: Text(
                'No Posters Available',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                ),
              ),
            );
          }

          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Main poster PageView
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: PageView.builder(
                      controller: _pageController,
                      allowImplicitScrolling: true,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                        // Preload the next one
                        _precachePoster(index + 1);
                      },
                      itemCount: dataProvider.posters.length,
                      itemBuilder: (context, index) {
                        // Use firstWhereOrNull to avoid the "Bad state: No element" error
                        final product =
                            context.dataProvider.allProducts.firstWhereOrNull(
                          (product) =>
                              product.sId ==
                              dataProvider.posters[index].productId,
                        );

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _getPosterGradient(index),
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _getPosterGradient(index)[0]
                                    .withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background image with parallax
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Hero(
                                    tag:
                                        'poster_${dataProvider.posters[index].imageUrl}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Smooth blurred background image to blend with card gradient
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 800),
                                            child: dataProvider.posters[index]
                                                        .imageUrl?.isNotEmpty ==
                                                    true
                                                ? ImageFiltered(
                                                    key: ValueKey(dataProvider
                                                        .posters[index]
                                                        .imageUrl),
                                                    imageFilter:
                                                        ui.ImageFilter.blur(
                                                            sigmaX: 8,
                                                            sigmaY: 8),
                                                    child: Image.network(
                                                      '${dataProvider.posters[index].imageUrl}',
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors:
                                                                  _getPosterGradient(
                                                                      index),
                                                            ),
                                                          ),
                                                          child: const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color: Colors
                                                                  .white54,
                                                              strokeWidth: 2,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors:
                                                                  _getPosterGradient(
                                                                      index),
                                                            ),
                                                          ),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                              color: Colors
                                                                  .white54,
                                                              size: 48,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Container(
                                                    key: ValueKey(
                                                        'empty_${index}'),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors:
                                                            _getPosterGradient(
                                                                index),
                                                      ),
                                                    ),
                                                  ),
                                          ),

                                          // Sharp overlay for the actual crisp image
                                          Positioned.fill(
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 800),
                                              child: dataProvider
                                                          .posters[index]
                                                          .imageUrl
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? Image.network(
                                                      key: ValueKey(
                                                          'sharp_${dataProvider.posters[index].imageUrl}'),
                                                      '${dataProvider.posters[index].imageUrl}',
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return const SizedBox();
                                                      },
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const SizedBox();
                                                      },
                                                    )
                                                  : const SizedBox(),
                                            ),
                                          ),

                                          // Dark overlay for text readability
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.3),
                                                  Colors.black.withOpacity(0.7),
                                                ],
                                                stops: const [0.0, 0.6, 1.0],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Enhanced CTA Button - Top Right
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(25),
                                      onTap: product != null
                                          ? () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      ProductDetailScreen(
                                                          product),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: const Offset(
                                                            1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(CurvedAnimation(
                                                        parent: animation,
                                                        curve: Curves
                                                            .easeInOutCubic,
                                                      )),
                                                      child: FadeTransition(
                                                        opacity: animation,
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  transitionDuration:
                                                      const Duration(
                                                          milliseconds: 600),
                                                ),
                                              );
                                            }
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (product != null) ...[
                                              Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 16,
                                                color: _getPosterGradient(
                                                    index)[0],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Shop Now",
                                                style: TextStyle(
                                                  color: _getPosterGradient(
                                                      index)[0],
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ] else ...[
                                              Icon(
                                                Icons.explore_outlined,
                                                size: 16,
                                                color: _getPosterGradient(
                                                    index)[0],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Explore",
                                                style: TextStyle(
                                                  color: _getPosterGradient(
                                                      index)[0],
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Enhanced Text Content - Bottom Left
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 100, // Give space for CTA button
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${dataProvider.posters[index].posterName}',
                                      style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 22,
                                            letterSpacing: 0.3,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                offset: const Offset(0, 1),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ) ??
                                          const TextStyle(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (product != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Starting from \$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          shadows: [
                                            Shadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              offset: const Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Enhanced Carousel Indicators
                  if (dataProvider.posters.length > 1)
                    Positioned(
                      bottom: 25,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: dataProvider.posters
                                .asMap()
                                .entries
                                .map((entry) {
                              final isActive = entry.key == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                height: 6,
                                width: isActive ? 20 : 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
