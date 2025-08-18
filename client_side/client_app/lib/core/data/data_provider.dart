import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../../models/category.dart';
import '../../models/api_response.dart';
import '../../models/brand.dart';
import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/sub_category.dart';
import '../../models/user.dart';
import '../../services/http_services.dart';
import '../../utility/snack_bar_helper.dart';

class DataProvider extends ChangeNotifier {
  HttpService service = HttpService();

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  List<Category> get categories => _filteredCategories;

  List<SubCategory> _allSubCategories = [];
  List<SubCategory> _filteredSubCategories = [];

  List<SubCategory> get subCategories => _filteredSubCategories;

  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];
  List<Brand> get brands => _filteredBrands;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts;

  List<Poster> _allPosters = [];
  List<Poster> _filteredPosters = [];
  List<Poster> get posters => _filteredPosters;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Order> get orders => _filteredOrders;

  DataProvider() {
    getAllProduct();
    getAllCategory();
    getAllSubCategory();
    getAllBrands();
    getAllPosters();
  }

  Future<List<Category>> getAllCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'categories');
      if (response.isOk) {
        ApiResponse<List<Category>> apiResponse =
            ApiResponse<List<Category>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Category.fromJson(item)).toList(),
        );
        _allCategories = apiResponse.data ?? [];
        _filteredCategories =
            List.from(_allCategories); // Initialize filtered list with all data
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredCategories;
  }

  void filterCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredCategories = _allCategories.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<SubCategory>> getAllSubCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'subCategories');
      if (response.isOk) {
        ApiResponse<List<SubCategory>> apiResponse =
            ApiResponse<List<SubCategory>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => SubCategory.fromJson(item)).toList(),
        );
        _allSubCategories = apiResponse.data ?? [];
        _filteredSubCategories = List.from(
            _allSubCategories); // Initialize filtered list with all data
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredSubCategories;
  }

  void filterSubCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredSubCategories = List.from(_allSubCategories);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredSubCategories = _allSubCategories.where((subcategory) {
        return (subcategory.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'brands');
      if (response.isOk) {
        ApiResponse<List<Brand>> apiResponse =
            ApiResponse<List<Brand>>.fromJson(
          response.body,
          (json) => (json as List).map((item) => Brand.fromJson(item)).toList(),
        );
        _allBrands = apiResponse.data ?? [];
        _filteredBrands =
            List.from(_allBrands); // Initialize filtered list with all data
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredBrands;
  }

  void filterBrands(String keyword) {
    if (keyword.isEmpty) {
      _filteredBrands = List.from(_allBrands);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredBrands = _allBrands.where((brand) {
        return (brand.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> getAllProduct({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'products');
      ApiResponse<List<Product>> apiResponse =
          ApiResponse<List<Product>>.fromJson(
        response.body,
        (json) => (json as List).map((item) => Product.fromJson(item)).toList(),
      );
      _allProducts = apiResponse.data ?? [];
      _filteredProducts =
          List.from(_allProducts); // Initialize with original data
      notifyListeners();
      if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
    }
  }

  void filterProducts(String keyword) {
    if (keyword.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final lowerKeyword = keyword.toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final productNameContainsKeyword =
            (product.name ?? '').toLowerCase().contains(lowerKeyword);
        final categoryNameContainsKeyword = product.proSubCategoryId?.name
                ?.toLowerCase()
                .contains(lowerKeyword) ??
            false;
        final subCategoryNameContainsKeyword = product.proSubCategoryId?.name
                ?.toLowerCase()
                .contains(lowerKeyword) ??
            false;

        //? You can add more conditions here if there are more fields to match against
        return productNameContainsKeyword ||
            categoryNameContainsKeyword ||
            subCategoryNameContainsKeyword;
      }).toList();
    }
    notifyListeners();
  }

  void applyAdvancedFilters({
    String? keyword,
    RangeValues? priceRange,
    List<String>? categories,
    List<String>? brands,
    String? sortBy,
    double? minRating,
  }) {
    _filteredProducts = List.from(_allProducts);

    // Apply keyword filter
    if (keyword != null && keyword.isNotEmpty) {
      final lowerKeyword = keyword.toLowerCase();
      _filteredProducts = _filteredProducts.where((product) {
        final productNameContainsKeyword =
            (product.name ?? '').toLowerCase().contains(lowerKeyword);
        final categoryNameContainsKeyword =
            product.proCategoryId?.name?.toLowerCase().contains(lowerKeyword) ??
                false;
        final subCategoryNameContainsKeyword = product.proSubCategoryId?.name
                ?.toLowerCase()
                .contains(lowerKeyword) ??
            false;
        return productNameContainsKeyword ||
            categoryNameContainsKeyword ||
            subCategoryNameContainsKeyword;
      }).toList();
    }

    // Apply price range filter
    if (priceRange != null) {
      _filteredProducts = _filteredProducts.where((product) {
        final price = product.offerPrice ?? product.price ?? 0;
        return price >= priceRange.start && price <= priceRange.end;
      }).toList();
    }

    // Apply category filter (by ID)
    if (categories != null && categories.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return categories.contains(product.proCategoryId?.sId);
      }).toList();
    }

    // Apply brand filter (by ID)
    if (brands != null && brands.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return brands.contains(product.proBrandId?.sId);
      }).toList();
    }

    // Apply sorting
    if (sortBy != null) {
      switch (sortBy) {
        case 'price_low':
          _filteredProducts.sort((a, b) {
            final priceA = a.offerPrice ?? a.price ?? 0;
            final priceB = b.offerPrice ?? b.price ?? 0;
            return priceA.compareTo(priceB);
          });
          break;
        case 'price_high':
          _filteredProducts.sort((a, b) {
            final priceA = a.offerPrice ?? a.price ?? 0;
            final priceB = b.offerPrice ?? b.price ?? 0;
            return priceB.compareTo(priceA);
          });
          break;
        case 'name':
          _filteredProducts
              .sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
          break;
      }
    }

    notifyListeners();
  }

  void clearFilters() {
    _filteredProducts = List.from(_allProducts);
    notifyListeners();
  }

  void sortProductsByPrice({required bool ascending}) {
    _filteredProducts.sort((a, b) {
      final priceA = a.offerPrice ?? a.price ?? 0;
      final priceB = b.offerPrice ?? b.price ?? 0;
      if (ascending) {
        return priceA.compareTo(priceB);
      } else {
        return priceB.compareTo(priceA);
      }
    });
    notifyListeners();
  }

  void sortProductsByName() {
    _filteredProducts.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    notifyListeners();
  }

  void filterByCategories(List<String> categoryIds) {
    if (categoryIds.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts.where((product) {
        return categoryIds.contains(product.proCategoryId?.sId);
      }).toList();
    }
    notifyListeners();
  }

  void filterByPriceRange(double minPrice, double maxPrice) {
    _filteredProducts = _filteredProducts.where((product) {
      final price = product.offerPrice ?? product.price ?? 0;
      return price >= minPrice && price <= maxPrice;
    }).toList();
    notifyListeners();
  }

  void applyFilters({
    List<String>? categories,
    List<String>? brands,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) {
    print('🔥 APPLYING FILTERS:');
    print('🔥 categories: $categories');
    print('🔥 brands: $brands');
    print('🔥 minPrice: $minPrice, maxPrice: $maxPrice');
    print('🔥 sortBy: $sortBy');
    print('🔥 Total products before filter: ${_allProducts.length}');

    // Start with all products
    _filteredProducts = List.from(_allProducts);

    // Apply category filter
    if (categories != null && categories.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return categories.contains(product.proCategoryId?.sId);
      }).toList();
      print('🔥 After category filter: ${_filteredProducts.length}');
    }

    // Apply brand filter
    if (brands != null && brands.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return brands.contains(product.proBrandId?.sId);
      }).toList();
      print('🔥 After brand filter: ${_filteredProducts.length}');
    }

    // Apply price range filter
    if (minPrice != null && maxPrice != null) {
      _filteredProducts = _filteredProducts.where((product) {
        final price = product.offerPrice ?? product.price ?? 0;
        return price >= minPrice && price <= maxPrice;
      }).toList();
      print('🔥 After price filter: ${_filteredProducts.length}');
    }

    // Apply sorting
    if (sortBy != null) {
      print('🔥 Applying sort: $sortBy');
      switch (sortBy) {
        case 'Price: Low to High':
        case 'price_low':
          sortProductsByPrice(ascending: true);
          print('🔥 Sorted by price low to high');
          return; // sortProductsByPrice already calls notifyListeners
        case 'Price: High to Low':
        case 'price_high':
          sortProductsByPrice(ascending: false);
          print('🔥 Sorted by price high to low');
          return; // sortProductsByPrice already calls notifyListeners
        case 'Name: A-Z':
        case 'name':
          sortProductsByName();
          print('🔥 Sorted by name');
          return; // sortProductsByName already calls notifyListeners
      }
    }

    print('🔥 Final filtered products: ${_filteredProducts.length}');
    notifyListeners();
  }

  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'posters');
      if (response.isOk) {
        ApiResponse<List<Poster>> apiResponse =
            ApiResponse<List<Poster>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Poster.fromJson(item)).toList(),
        );
        _allPosters = apiResponse.data ?? [];
        _filteredPosters = List.from(_allPosters);
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredPosters;
  }

  double calculateDiscountPercentage(num originalPrice, num? discountedPrice) {
    if (originalPrice <= 0) {
      throw ArgumentError('Original price must be greater than zero.');
    }

    //? Ensure discountedPrice is not null; if it is, default to the original price (no discount)
    num finalDiscountedPrice = discountedPrice ?? originalPrice;

    if (finalDiscountedPrice > originalPrice) {
      throw ArgumentError(
          'Discounted price must not be greater than the original price.');
    }

    double discount =
        ((originalPrice - finalDiscountedPrice) / originalPrice) * 100;

    //? Return the discount percentage as an integer
    return discount;
  }

  Future<List<Order>> getAllOrderByUser(User? user,
      {bool showSnack = false}) async {
    try {
      String userId = user?.sId ?? '';
      Response response =
          await service.getItems(endpointUrl: 'orders/orderByUserId/$userId');
      if (response.isOk) {
        ApiResponse<List<Order>> apiResponse =
            ApiResponse<List<Order>>.fromJson(
          response.body,
          (json) => (json as List).map((item) => Order.fromJson(item)).toList(),
        );
        print(apiResponse.message);
        _allOrders = apiResponse.data ?? [];
        _filteredOrders = List.from(_allOrders);
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredOrders;
  }
}
