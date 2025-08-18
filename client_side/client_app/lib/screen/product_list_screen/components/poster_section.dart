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
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      if (dataProvider.posters.isNotEmpty) {
        _currentPage = (_currentPage + 1) % dataProvider.posters.length;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
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
              return FadeTransition(
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
                          product.sId == dataProvider.posters[index].productId,
                    );

                    // Removed verbose debug prints

                    // Show poster regardless of whether product exists or not
                    // Parallax disabled to ensure full image visibility

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
                            color:
                                _getPosterGradient(index)[0].withOpacity(0.3),
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
                                        duration:
                                            const Duration(milliseconds: 600),
                                        switchInCurve: Curves.easeInOut,
                                        switchOutCurve: Curves.easeInOut,
                                        child: ImageFiltered(
                                          key: ValueKey(
                                              'bg_${dataProvider.posters[index].imageUrl}'),
                                          imageFilter: ui.ImageFilter.blur(
                                              sigmaX: 10, sigmaY: 10),
                                          child: Image.network(
                                            '${dataProvider.posters[index].imageUrl}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      // Foreground contained image with smooth transition
                                      Center(
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 600),
                                          switchInCurve: Curves.easeInOut,
                                          switchOutCurve: Curves.easeInOut,
                                          child: Image.network(
                                            '${dataProvider.posters[index].imageUrl}',
                                            key: ValueKey(
                                                'fg_${dataProvider.posters[index].imageUrl}'),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      // Gradient overlay for readability
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.0),
                                              Colors.black.withOpacity(0.25),
                                              Colors.black.withOpacity(0.55),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Foreground content
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  // Text and CTA
                                  Expanded(
                                    flex: 45,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 20,
                                                    letterSpacing: 0.2,
                                                  ) ??
                                              const TextStyle(),
                                          child: Text(
                                            '${dataProvider.posters[index].posterName}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Material(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(25),
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
                                                        transitionsBuilder:
                                                            (context,
                                                                animation,
                                                                secondaryAnimation,
                                                                child) {
                                                          return SlideTransition(
                                                            position: Tween<
                                                                Offset>(
                                                              begin:
                                                                  const Offset(
                                                                      1.0, 0.0),
                                                              end: Offset.zero,
                                                            ).animate(
                                                                CurvedAnimation(
                                                              parent: animation,
                                                              curve: Curves
                                                                  .easeInOutCubic,
                                                            )),
                                                            child:
                                                                FadeTransition(
                                                              opacity:
                                                                  animation,
                                                              child: child,
                                                            ),
                                                          );
                                                        },
                                                        transitionDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    600),
                                                      ),
                                                    );
                                                  }
                                                : null,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 10),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (product != null)
                                                    Text(
                                                      "Shop Now",
                                                      style: TextStyle(
                                                        color:
                                                            _getPosterGradient(
                                                                index)[0],
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  const SizedBox(width: 6),
                                                  if (product != null)
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      size: 14,
                                                      color: _getPosterGradient(
                                                          index)[0],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Spacer to let the image shine
                                  const Expanded(flex: 55, child: SizedBox()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
