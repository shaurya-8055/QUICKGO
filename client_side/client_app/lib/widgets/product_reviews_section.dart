import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/rating_distribution.dart';
import '../widgets/review_card.dart';
import '../widgets/add_review_dialog.dart';

class ProductReviewsSection extends StatefulWidget {
  final String productId;
  final String? userId;
  final String? userToken;

  const ProductReviewsSection({
    Key? key,
    required this.productId,
    this.userId,
    this.userToken,
  }) : super(key: key);

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  ProductRating? _productRating;
  List<Review> _reviews = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _canUserReview = false;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreReviews = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMoreReviews) {
      _loadMoreReviews();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load rating summary and initial reviews
      final futures = [
        ReviewService.getProductRating(widget.productId),
        ReviewService.getProductReviews(
          widget.productId,
          page: 1,
          limit: _pageSize,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
        ),
      ];

      // Check if user can review (only if user is logged in)
      if (widget.userId != null && widget.userToken != null) {
        futures.add(
          ReviewService.canUserReview(
            widget.productId,
            widget.userId!,
            widget.userToken!,
          ),
        );
      }

      final results = await Future.wait(futures);

      setState(() {
        _productRating = results[0] as ProductRating;
        _reviews = results[1] as List<Review>;
        if (results.length > 2) {
          _canUserReview = results[2] as bool;
        }
        _hasMoreReviews = _reviews.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reviews: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoadingMore || !_hasMoreReviews) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newReviews = await ReviewService.getProductReviews(
        widget.productId,
        page: _currentPage + 1,
        limit: _pageSize,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      setState(() {
        _currentPage++;
        _reviews.addAll(newReviews);
        _hasMoreReviews = newReviews.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading more reviews: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _changeSorting(String sortBy, String sortOrder) {
    if (_sortBy == sortBy && _sortOrder == sortOrder) return;

    setState(() {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
      _currentPage = 1;
      _reviews.clear();
      _hasMoreReviews = true;
    });

    _loadInitialData();
  }

  Future<void> _showAddReviewDialog() async {
    if (widget.userId == null || widget.userToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to write a review'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_canUserReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You can only review products you have purchased and received'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        onSubmit: _submitReview,
      ),
    );
  }

  Future<void> _submitReview(
    double rating,
    String title,
    String comment,
    List<String> images,
  ) async {
    try {
      await ReviewService.submitReview(
        productId: widget.productId,
        userId: widget.userId!,
        rating: rating,
        comment: comment,
        title: title.isNotEmpty ? title : null,
        images: images.isNotEmpty ? images : null,
        token: widget.userToken!,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh reviews
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markReviewHelpful(String reviewId) async {
    if (widget.userToken == null) return;

    try {
      await ReviewService.markReviewHelpful(reviewId, widget.userToken!);

      // Update the review in the list
      setState(() {
        final index = _reviews.indexWhere((r) => r.sId == reviewId);
        if (index != -1) {
          _reviews[index].helpfulCount =
              (_reviews[index].helpfulCount ?? 0) + 1;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Section header with write review button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Reviews & Ratings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (_canUserReview)
                ElevatedButton.icon(
                  onPressed: _showAddReviewDialog,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Write Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Rating distribution
        if (_productRating != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RatingDistributionWidget(productRating: _productRating!),
          ),

        const SizedBox(height: 24),

        // Sorting options
        if (_reviews.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Sort by:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _buildSortChip('Newest', 'createdAt', 'desc'),
                      _buildSortChip('Oldest', 'createdAt', 'asc'),
                      _buildSortChip('Highest Rating', 'rating', 'desc'),
                      _buildSortChip('Lowest Rating', 'rating', 'asc'),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Reviews list
        if (_reviews.isEmpty && !_isLoading)
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No reviews yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to review this product',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                if (_canUserReview) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddReviewDialog,
                    child: const Text('Write First Review'),
                  ),
                ],
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ..._reviews.map((review) => ReviewCard(
                      review: review,
                      isCurrentUser: review.userId == widget.userId,
                      onHelpful: () => _markReviewHelpful(review.sId!),
                    )),

                // Load more indicator
                if (_isLoadingMore)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                else if (!_hasMoreReviews && _reviews.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No more reviews',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSortChip(String label, String sortBy, String sortOrder) {
    final theme = Theme.of(context);
    final isSelected = _sortBy == sortBy && _sortOrder == sortOrder;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _changeSorting(sortBy, sortOrder);
        }
      },
      selectedColor: theme.colorScheme.primaryContainer,
      backgroundColor: theme.colorScheme.surface,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withOpacity(0.5),
      ),
    );
  }
}
