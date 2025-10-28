import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/technician.dart';
import '../../../models/api_response.dart';
import '../../../services/http_services.dart';

class TechnicianProvider with ChangeNotifier {
  final HttpService _httpService = HttpService();

  List<Technician> _allTechnicians = [];
  List<Technician> _filteredTechnicians = [];
  bool _isLoading = false;
  String? _error;

  List<Technician> get allTechnicians => _allTechnicians;
  List<Technician> get filteredTechnicians => _filteredTechnicians;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load technicians from API
  Future<void> loadTechnicians({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (category != null) {
        // Convert category to skill format (e.g., "AC Repair" -> "ac")
        final skill = _categoryToSkill(category);
        if (skill != null) {
          queryParams['skills'] = skill;
        }
      }
      queryParams['active'] = 'true';

      // Build query string from queryParams
      String endpoint = 'technicians';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        endpoint = 'technicians?$queryString';
      }

      final response = await _httpService.getItems(
        endpointUrl: endpoint,
      );

      final apiResponse = ApiResponse<List<Technician>>.fromJson(
        response.body,
        (json) =>
            (json as List).map((item) => Technician.fromJson(item)).toList(),
      );

      _allTechnicians = apiResponse.data ?? [];
      _filteredTechnicians = List.from(_allTechnicians);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load technicians near a specific location
  Future<void> loadNearbyTechnicians({
    required String category,
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    await loadTechnicians(category: category);

    // Filter by distance
    _filteredTechnicians = _allTechnicians.where((tech) {
      final distance = tech.distanceFrom(latitude, longitude);
      return distance != null && distance <= radiusKm;
    }).toList();

    // Sort by distance
    _filteredTechnicians.sort((a, b) {
      final distA = a.distanceFrom(latitude, longitude) ?? double.infinity;
      final distB = b.distanceFrom(latitude, longitude) ?? double.infinity;
      return distA.compareTo(distB);
    });

    notifyListeners();
  }

  /// Apply filters to technicians
  void applyFilters({
    double? minRating,
    double? maxPrice,
    bool? verifiedOnly,
  }) {
    _filteredTechnicians = _allTechnicians.where((tech) {
      if (minRating != null && tech.rating < minRating) return false;
      if (maxPrice != null &&
          tech.pricePerHour != null &&
          tech.pricePerHour! > maxPrice) return false;
      if (verifiedOnly == true && !tech.verified) return false;
      return true;
    }).toList();

    notifyListeners();
  }

  /// Search technicians by name or skills
  void search(String query) {
    if (query.isEmpty) {
      _filteredTechnicians = List.from(_allTechnicians);
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredTechnicians = _allTechnicians.where((tech) {
        return tech.name.toLowerCase().contains(lowerQuery) ||
            tech.skills
                .any((skill) => skill.toLowerCase().contains(lowerQuery));
      }).toList();
    }
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _filteredTechnicians = List.from(_allTechnicians);
    notifyListeners();
  }

  String? _categoryToSkill(String category) {
    final Map<String, String> categoryMap = {
      'AC Repair': 'ac',
      'Mobile Repair': 'mobile',
      'Appliance Repair': 'appliance',
      'Electrician': 'electrical',
      'Plumber': 'plumbing',
      'Painter': 'painting',
    };
    return categoryMap[category];
  }
}
