import 'package:flutter/material.dart';
import '../models/review.dart';
import '../widgets/enhanced_review_card.dart';
import '../widgets/star_rating.dart';
import '../widgets/add_review_dialog.dart';
import '../data/dummy_review_data.dart';

enum ReviewSortOption {
  newest,
  oldest,
  highest,
  lowest,
  helpful,
}

enum ReviewFilterOption {
  all,
  fiveStar,
  fourStar,
  threeStar,
  twoStar,
  oneStar,
  withImages,
  verified,
}

class AdvancedReviewsSection extends StatefulWidget {
  final String productId;
  final String? userId;
  final bool canAddReview;
  final ProductRating? productRating;
  final VoidCallback? onReviewAdded;

  const AdvancedReviewsSection({
    Key? key,
    required this.productId,
    this.userId,
    this.canAddReview = false,
    this.productRating,
    this.onReviewAdded,
  }) : super(key: key);

  @override
  State<AdvancedReviewsSection> createState() => _AdvancedReviewsSectionState();
}

class _AdvancedReviewsSectionState extends State<AdvancedReviewsSection>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  List<Review> _reviews = [];
  List<Review> _filteredReviews = [];
  ProductRating? _productRating;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  ReviewSortOption _currentSort = ReviewSortOption.newest;
  ReviewFilterOption _currentFilter = ReviewFilterOption.all;

  // Pagination
  bool _hasMoreReviews = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    // Use dummy data for development
    setState(() {
      _reviews = DummyReviewData.getReviewsForProduct(widget.productId);
      _productRating = DummyReviewData.getProductRating(widget.productId);
      _filteredReviews = _reviews;
    });
    _applyFiltersAndSort();
  }

  Future<void> _loadReviews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Using dummy data for development
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _reviews = DummyReviewData.getReviewsForProduct(widget.productId);
        _productRating = DummyReviewData.getProductRating(widget.productId);
        _filteredReviews = _reviews;
        _isLoading = false;
      });
      _applyFiltersAndSort();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreReviews();
    }
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoadingMore || !_hasMoreReviews) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more reviews
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoadingMore = false;
      // Simulate no more reviews for demo
      _hasMoreReviews = false;
    });
  }

  void _applyFiltersAndSort() {
    List<Review> filtered = List.from(_reviews);

    // Apply filter
    switch (_currentFilter) {
      case ReviewFilterOption.fiveStar:
        filtered = filtered.where((r) => r.rating == 5.0).toList();
        break;
      case ReviewFilterOption.fourStar:
        filtered = filtered.where((r) => r.rating == 4.0).toList();
        break;
      case ReviewFilterOption.threeStar:
        filtered = filtered.where((r) => r.rating == 3.0).toList();
        break;
      case ReviewFilterOption.twoStar:
        filtered = filtered.where((r) => r.rating == 2.0).toList();
        break;
      case ReviewFilterOption.oneStar:
        filtered = filtered.where((r) => r.rating == 1.0).toList();
        break;
      case ReviewFilterOption.withImages:
        filtered = filtered.where((r) => r.images?.isNotEmpty == true).toList();
        break;
      case ReviewFilterOption.verified:
        filtered = filtered.where((r) => r.isVerifiedPurchase == true).toList();
        break;
      case ReviewFilterOption.all:
        break;
    }

    // Apply sort
    switch (_currentSort) {
      case ReviewSortOption.newest:
        filtered.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        break;
      case ReviewSortOption.oldest:
        filtered.sort((a, b) => (a.createdAt ?? DateTime.now())
            .compareTo(b.createdAt ?? DateTime.now()));
        break;
      case ReviewSortOption.highest:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case ReviewSortOption.lowest:
        filtered.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
        break;
      case ReviewSortOption.helpful:
        filtered.sort(
            (a, b) => (b.helpfulCount ?? 0).compareTo(a.helpfulCount ?? 0));
        break;
    }

    setState(() {
      _filteredReviews = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _reviews.isEmpty) {
      return _buildLoadingState();
    }

    if (_hasError && _reviews.isEmpty) {
      return _buildErrorState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(),
        const SizedBox(height: 16),

        // Rating summary
        if (_productRating != null) ...[
          _buildRatingSummary(),
          const SizedBox(height: 24),
        ],

        // Filters and sort
        _buildFiltersAndSort(),
        const SizedBox(height: 16),

        // Reviews list
        _buildReviewsList(),

        // Load more button/indicator
        if (_isLoadingMore)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Customer Reviews',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        if (widget.canAddReview)
          ElevatedButton.icon(
            onPressed: _showAddReviewDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingSummary() {
    if (_productRating == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Overall rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      (_productRating!.averageRating ?? 0.0).toStringAsFixed(1),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    const SizedBox(width: 8),
                    StarRating(
                      rating: _productRating!.averageRating ?? 0.0,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_productRating!.totalReviews ?? 0} reviews',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),

          // Rating distribution
          Expanded(
            child: _buildRatingDistribution(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    if (_productRating == null) return const SizedBox.shrink();

    return Column(
      children: [
        for (int i = 5; i >= 1; i--)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text('$i'),
                const SizedBox(width: 4),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _getRatingPercentage(i),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(_getRatingPercentage(i) * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }

  double _getRatingPercentage(int rating) {
    if (_productRating == null || (_productRating!.totalReviews ?? 0) == 0)
      return 0.0;

    int count = _productRating!.ratingDistribution?[rating] ?? 0;

    return count / (_productRating!.totalReviews ?? 1);
  }

  Widget _buildFiltersAndSort() {
    return Row(
      children: [
        // Filter dropdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ReviewFilterOption>(
                value: _currentFilter,
                isExpanded: true,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currentFilter = value;
                    });
                    _applyFiltersAndSort();
                  }
                },
                items: ReviewFilterOption.values
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(_getFilterLabel(option)),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Sort dropdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ReviewSortOption>(
                value: _currentSort,
                isExpanded: true,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currentSort = value;
                    });
                    _applyFiltersAndSort();
                  }
                },
                items: ReviewSortOption.values
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(_getSortLabel(option)),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    if (_filteredReviews.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _filteredReviews.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: EnhancedReviewCard(
            review: _filteredReviews[index],
            onHelpful: () => _onReviewHelpful(_filteredReviews[index]),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading reviews...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load reviews',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadReviews,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(ReviewFilterOption option) {
    switch (option) {
      case ReviewFilterOption.all:
        return 'All Reviews';
      case ReviewFilterOption.fiveStar:
        return '5 Stars';
      case ReviewFilterOption.fourStar:
        return '4 Stars';
      case ReviewFilterOption.threeStar:
        return '3 Stars';
      case ReviewFilterOption.twoStar:
        return '2 Stars';
      case ReviewFilterOption.oneStar:
        return '1 Star';
      case ReviewFilterOption.withImages:
        return 'With Images';
      case ReviewFilterOption.verified:
        return 'Verified Purchase';
    }
  }

  String _getSortLabel(ReviewSortOption option) {
    switch (option) {
      case ReviewSortOption.newest:
        return 'Newest First';
      case ReviewSortOption.oldest:
        return 'Oldest First';
      case ReviewSortOption.highest:
        return 'Highest Rating';
      case ReviewSortOption.lowest:
        return 'Lowest Rating';
      case ReviewSortOption.helpful:
        return 'Most Helpful';
    }
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        onSubmit: (rating, title, comment, images) {
          // Handle review submission
          widget.onReviewAdded?.call();
          _loadReviews();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _onReviewHelpful(Review review) {
    // Implement helpful functionality
    setState(() {
      review.helpfulCount = (review.helpfulCount ?? 0) + 1;
    });
  }
}
