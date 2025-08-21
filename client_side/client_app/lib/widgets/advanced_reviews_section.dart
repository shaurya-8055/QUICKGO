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
  // Removed unused and undefined controllers
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
  // Removed unused pagination fields
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
      // Replace with actual API call
      // final reviews = await _reviewService.getProductReviews(widget.productId);
      // final rating = await _reviewService.getProductRating(widget.productId);

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
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _isLoadingMore = false;
      // For demo, we'll just mark as no more reviews
      _hasMoreReviews = false;
    });
  }

  void _applyFiltersAndSort() {
    List<Review> filtered = List.from(_reviews);

    // Apply filters
    switch (_currentFilter) {
      case ReviewFilterOption.fiveStar:
        filtered = filtered.where((r) => r.rating == 5).toList();
        break;
      case ReviewFilterOption.fourStar:
        filtered = filtered.where((r) => r.rating == 4).toList();
        break;
      case ReviewFilterOption.threeStar:
        filtered = filtered.where((r) => r.rating == 3).toList();
        break;
      case ReviewFilterOption.twoStar:
        filtered = filtered.where((r) => r.rating == 2).toList();
        break;
      case ReviewFilterOption.oneStar:
        filtered = filtered.where((r) => r.rating == 1).toList();
        break;
      case ReviewFilterOption.withImages:
        filtered = filtered
            .where((r) => r.images != null && r.images!.isNotEmpty)
            .toList();
        break;
      case ReviewFilterOption.verified:
        filtered = filtered.where((r) => r.isVerifiedPurchase == true).toList();
        break;
      case ReviewFilterOption.all:
        break;
    }

    // Apply sorting
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

  void _changeSortOption(ReviewSortOption option) {
    setState(() {
      _currentSort = option;
    });
    _applyFiltersAndSort();
  }

  void _changeFilterOption(ReviewFilterOption option) {
    setState(() {
      _currentFilter = option;
    });
    _applyFiltersAndSort();
  }

  String _getSortOptionText(ReviewSortOption option) {
    switch (option) {
      case ReviewSortOption.newest:
        return 'Newest';
      case ReviewSortOption.oldest:
        return 'Oldest';
      case ReviewSortOption.highest:
        return 'Highest Rated';
      case ReviewSortOption.lowest:
        return 'Lowest Rated';
      case ReviewSortOption.helpful:
        return 'Most Helpful';
    }
  }

  String _getFilterOptionText(ReviewFilterOption option) {
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
        return 'Verified Only';
    }
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        onSubmit: (rating, title, comment, images) {
          // Create a new Review object (dummy, for demo)
          final review = Review(
            userId: widget.userId,
            productId: widget.productId,
            rating: rating,
            title: title,
            comment: comment,
            images: images,
            createdAt: DateTime.now(),
            isVerifiedPurchase: true,
            helpfulCount: 0,
          );
          setState(() {
            _reviews.insert(0, review);
            _filteredReviews = _reviews;
          });
          _applyFiltersAndSort();
          if (widget.onReviewAdded != null) {
            widget.onReviewAdded!();
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        color: theme.colorScheme.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  if (_productRating != null) ...[
                    _buildRatingSummary(theme),
                    const SizedBox(height: 24),
                  ],
                  _buildFiltersAndSort(theme),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading && _filteredReviews.isEmpty) {
                    return _buildLoadingState();
                  } else if (_hasError && _filteredReviews.isEmpty) {
                    return _buildErrorState(theme);
                  } else if (_filteredReviews.isEmpty) {
                    return _buildEmptyState(theme);
                  } else {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _buildReviewsList(),
                    );
                  }
                },
              ),
            ),
            if (widget.canAddReview)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.background.withOpacity(0.95),
                child: ElevatedButton.icon(
                  onPressed: _showAddReviewDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Review',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Customer Reviews',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (widget.canAddReview)
          ElevatedButton.icon(
            onPressed: _showAddReviewDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Write Review'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingSummary(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Overall rating
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        (_productRating?.averageRating ?? 0.0)
                            .toStringAsFixed(1),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: StarRating(
                          rating: _productRating?.averageRating ?? 0.0,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_productRating?.totalReviews ?? 0} reviews',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSort(ThemeData theme) {
    return Row(
      children: [
        // Filter dropdown
        Expanded(
          child: PopupMenuButton<ReviewFilterOption>(
            onSelected: _changeFilterOption,
            initialValue: _currentFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getFilterOptionText(_currentFilter),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => ReviewFilterOption.values.map((option) {
              return PopupMenuItem<ReviewFilterOption>(
                value: option,
                child: Text(_getFilterOptionText(option)),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 12),
        // Sort dropdown
        Expanded(
          child: PopupMenuButton<ReviewSortOption>(
            onSelected: _changeSortOption,
            initialValue: _currentSort,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sort,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSortOptionText(_currentSort),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => ReviewSortOption.values.map((option) {
              return PopupMenuItem<ReviewSortOption>(
                value: option,
                child: Text(_getSortOptionText(option)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredReviews.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredReviews.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final review = _filteredReviews[index];
        return EnhancedReviewCard(
          review: review,
          isCurrentUser: review.user?.id == widget.userId,
          onHelpful: () {
            // Handle helpful action
          },
          onEdit: () {
            // Handle edit action
          },
          onDelete: () {
            // Handle delete action
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load reviews',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadReviews,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to write a review for this product',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.canAddReview) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _showAddReviewDialog,
                child: const Text('Write First Review'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
