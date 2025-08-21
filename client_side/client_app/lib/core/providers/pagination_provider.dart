import 'package:flutter/foundation.dart';
import '../../models/product.dart';

/// Optimized Pagination Provider for smooth data loading
/// Features: Page-based loading, efficient state management, minimal rebuilds
class PaginationProvider extends ChangeNotifier {
  static const int _pageSize = 20; // Load 20 products per page

  List<Product> _allProducts = [];
  List<Product> _displayedProducts = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  String _searchQuery = '';
  String _selectedCategory = '';

  // Getters
  List<Product> get displayedProducts => _displayedProducts;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;
  int get currentPage => _currentPage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  /// Initialize with all products from DataProvider
  void initializeProducts(List<Product> products) {
    _allProducts = products;
    _currentPage = 0;
    _hasMoreData = true;
    _displayedProducts.clear();
    _loadNextPage();
  }

  /// Load next page of products
  void loadNextPage() {
    if (_isLoading || !_hasMoreData) return;
    _loadNextPage();
  }

  void _loadNextPage() {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay for better UX (remove in production)
    Future.delayed(const Duration(milliseconds: 300), () {
      final filteredProducts = _getFilteredProducts();
      final startIndex = _currentPage * _pageSize;
      final endIndex =
          (startIndex + _pageSize).clamp(0, filteredProducts.length);

      if (startIndex >= filteredProducts.length) {
        _hasMoreData = false;
      } else {
        final newProducts = filteredProducts.sublist(startIndex, endIndex);
        _displayedProducts.addAll(newProducts);
        _currentPage++;

        // Check if more data is available
        _hasMoreData = endIndex < filteredProducts.length;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  /// Filter products by search query
  void searchProducts(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query;
    _resetPagination();
  }

  /// Filter products by category
  void filterByCategory(String categoryId) {
    if (_selectedCategory == categoryId) return;

    _selectedCategory = categoryId;
    _resetPagination();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _resetPagination();
  }

  /// Reset pagination and reload from first page
  void _resetPagination() {
    _currentPage = 0;
    _hasMoreData = true;
    _displayedProducts.clear();
    _loadNextPage();
  }

  /// Get filtered products based on current filters
  List<Product> _getFilteredProducts() {
    List<Product> filtered = _allProducts;

    // Apply category filter
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered
          .where((product) => product.proCategoryId?.sId == _selectedCategory)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        final name = product.name?.toLowerCase() ?? '';
        final description = product.description?.toLowerCase() ?? '';
        return name.contains(lowerQuery) || description.contains(lowerQuery);
      }).toList();
    }

    return filtered;
  }

  /// Sort products by price
  void sortByPrice({required bool ascending}) {
    _displayedProducts.sort((a, b) {
      final priceA = a.offerPrice ?? a.price ?? 0;
      final priceB = b.offerPrice ?? b.price ?? 0;
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    notifyListeners();
  }

  /// Sort products by popularity (based on price or other criteria)
  void sortByPopularity() {
    _displayedProducts.sort((a, b) {
      // Sort by price as popularity indicator (higher price = more premium)
      final priceA = a.offerPrice ?? a.price ?? 0;
      final priceB = b.offerPrice ?? b.price ?? 0;

      if (priceA != priceB) {
        return priceB.compareTo(priceA); // Higher price first
      }

      // If prices are equal, sort by name alphabetically
      return (a.name ?? '').compareTo(b.name ?? '');
    });
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    _resetPagination();
  }
}
