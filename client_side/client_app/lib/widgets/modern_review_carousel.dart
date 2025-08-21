import 'package:flutter/material.dart';
import '../models/review.dart';
import 'enhanced_review_card.dart';
import 'dart:async';

class ModernReviewCarousel extends StatefulWidget {
  final List<Review> reviews;
  const ModernReviewCarousel({Key? key, required this.reviews})
      : super(key: key);

  @override
  State<ModernReviewCarousel> createState() => _ModernReviewCarouselState();
}

class _ModernReviewCarouselState extends State<ModernReviewCarousel> {
  late PageController _controller;
  int _currentPage = 0;
  // removed unused _pageController
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.75, initialPage: 0);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (widget.reviews.length <= 1) return;
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_controller.hasClients) {
        int nextPage = (_currentPage + 1) % widget.reviews.length;
        _controller.animateToPage(
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.reviews.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            physics: const PageScrollPhysics(),
            itemBuilder: (context, i) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: _ModernReviewCardDark(review: widget.reviews[i]),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              widget.reviews.length,
              (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: theme.colorScheme.onSurface,
              onPressed: _currentPage > 0
                  ? () => _controller.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.ease)
                  : null,
            ),
            Text(
              '0${_currentPage + 1} / 0${widget.reviews.length}',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              color: theme.colorScheme.onSurface,
              onPressed: _currentPage < widget.reviews.length - 1
                  ? () => _controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.ease)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ModernReviewCardDark extends StatelessWidget {
  final Review review;
  const _ModernReviewCardDark({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.92),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review.user?.avatar != null &&
                          review.user!.avatar!.isNotEmpty
                      ? NetworkImage(review.user!.avatar!)
                      : null,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  radius: 22,
                  child: review.user?.avatar == null ||
                          review.user!.avatar!.isEmpty
                      ? Icon(Icons.person, color: Colors.white.withOpacity(0.7))
                      : null,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.name ?? 'Anonymous',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      review.createdAt != null
                          ? '${review.createdAt!.toLocal()}'.split(' ')[0]
                          : '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              review.title ?? '',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            if (review.comment != null && review.comment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  review.comment!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            if (review.images != null && review.images!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 14.0, bottom: 8.0),
                child: SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.images!.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, idx) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        review.images![idx],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.white.withOpacity(0.08),
                          child: Icon(Icons.broken_image,
                              color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (review.isVerifiedPurchase == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Icon(Icons.thumb_up_alt_outlined,
                    size: 18, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text('${review.helpfulCount ?? 0}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
