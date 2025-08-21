import 'package:client_app/utility/extensions.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../core/data/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui' as ui;
import '../../product_details_screen/product_detail_screen.dart';

class PosterSection extends StatefulWidget {
  const PosterSection({super.key});

  @override
  _PosterSectionState createState() => _PosterSectionState();
}

class _PosterSectionState extends State<PosterSection>
    with SingleTickerProviderStateMixin {
  Timer? _autoSlideTimer;
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    // Auto-slide every 3 seconds
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final provider = context.read<DataProvider>();
      final posterCount = provider.posters.length;
      if (posterCount > 1) {
        int nextPage = (_currentPage + 1) % posterCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _precachePoster(int index) {
    // Optionally implement image pre-caching for smoother transitions
  }

  List<Color> _getPosterGradient(int index) {
    // Example gradients, replace with your own logic if needed
    final gradients = [
      [Colors.blue.shade400, Colors.blue.shade900],
      [Colors.purple.shade400, Colors.purple.shade900],
      [Colors.orange.shade400, Colors.orange.shade900],
      [Colors.green.shade400, Colors.green.shade900],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    // Use dynamic height with aspect ratio, but cap the height for large screens
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      double aspectRatio = 16 / 7;
      double calculatedHeight = width / aspectRatio;
      double maxHeight = 220;
      double height =
          calculatedHeight > maxHeight ? maxHeight : calculatedHeight;
      return SizedBox(
        height: height,
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
            return Stack(
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView.builder(
                    controller: _pageController,
                    allowImplicitScrolling: true,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      _precachePoster(index + 1);
                    },
                    itemCount: dataProvider.posters.length,
                    itemBuilder: (context, index) {
                      double pageOffset = 0.0;
                      if (_pageController.hasClients &&
                          _pageController.page != null) {
                        pageOffset = _pageController.page! - index;
                      } else {
                        pageOffset = (_currentPage - index).toDouble();
                      }
                      // 3D/Parallax effect: scale and offset
                      final double scale =
                          1 - (pageOffset.abs() * 0.15).clamp(0.0, 0.3);
                      final double verticalOffset = 20 * pageOffset.abs();
                      final double parallax = 24 * pageOffset;
                      final bool isActive = index == _currentPage;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..scale(scale, scale)
                          ..translate(0.0, verticalOffset),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          // Outer gradient border
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getPosterGradient(index)[0],
                                _getPosterGradient(index)[1],
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              if (isActive)
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.35),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                              BoxShadow(
                                color: _getPosterGradient(index)[0]
                                    .withOpacity(0.18),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(5.0), // Thicker border
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Transform.translate(
                                  offset: Offset(parallax, 0),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (dataProvider.posters[index].imageUrl
                                              ?.isNotEmpty ==
                                          true)
                                        Image.network(
                                          '${dataProvider.posters[index].imageUrl}',
                                          fit: BoxFit.cover,
                                          color: Colors.black.withOpacity(0.18),
                                          colorBlendMode: BlendMode.darken,
                                        ),
                                      if (dataProvider.posters[index].imageUrl
                                              ?.isNotEmpty ==
                                          true)
                                        Positioned.fill(
                                          child: BackdropFilter(
                                            filter: ui.ImageFilter.blur(
                                                sigmaX: 16, sigmaY: 16),
                                            child: Container(
                                                color: Colors.transparent),
                                          ),
                                        ),
                                      if (dataProvider.posters[index].imageUrl
                                              ?.isNotEmpty ==
                                          true)
                                        Image.network(
                                          '${dataProvider.posters[index].imageUrl}',
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              color: Colors.transparent,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white54,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.transparent,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white54,
                                                  size: 48,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        Container(
                                          key: ValueKey('empty_${index}'),
                                          color: Colors.transparent,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (dataProvider.posters.length > 1)
                  Positioned(
                    bottom: 25,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: _currentPage,
                        count: dataProvider.posters.length,
                        effect: WormEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white.withOpacity(0.4),
                          spacing: 8,
                          paintStyle: PaintingStyle.fill,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    });
  }
}
