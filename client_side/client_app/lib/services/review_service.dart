import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import '../utility/constants.dart';

class ReviewService {
  static String get baseUrl => getMainUrl();

  // Get product reviews
  static Future<List<Review>> getProductReviews(String productId,
      {int page = 1,
      int limit = 10,
      String? sortBy = 'createdAt',
      String? sortOrder = 'desc'}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/reviews/product/$productId?page=$page&limit=$limit&sortBy=$sortBy&sortOrder=$sortOrder'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Review> reviews = [];
        if (data['data']['reviews'] != null) {
          reviews = (data['data']['reviews'] as List)
              .map((review) => Review.fromJson(review))
              .toList();
        }
        return reviews;
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  // Get product rating summary
  static Future<ProductRating> getProductRating(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/product/$productId/rating'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductRating.fromJson(data['data']);
      } else {
        throw Exception('Failed to load product rating');
      }
    } catch (e) {
      throw Exception('Error fetching product rating: $e');
    }
  }

  // Submit a review
  static Future<Review> submitReview({
    required String productId,
    required String userId,
    required double rating,
    required String comment,
    String? title,
    List<String>? images,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'productId': productId,
          'userId': userId,
          'rating': rating,
          'comment': comment,
          'title': title,
          'images': images,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Review.fromJson(data['data']['review']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit review');
      }
    } catch (e) {
      throw Exception('Error submitting review: $e');
    }
  }

  // Update a review
  static Future<Review> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
    String? title,
    List<String>? images,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'rating': rating,
          'comment': comment,
          'title': title,
          'images': images,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Review.fromJson(data['data']['review']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update review');
      }
    } catch (e) {
      throw Exception('Error updating review: $e');
    }
  }

  // Delete a review
  static Future<void> deleteReview(String reviewId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete review');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }

  // Mark review as helpful
  static Future<void> markReviewHelpful(String reviewId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/$reviewId/helpful'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to mark review as helpful');
      }
    } catch (e) {
      throw Exception('Error marking review as helpful: $e');
    }
  }

  // Check if user can review product (has purchased and delivered)
  static Future<bool> canUserReview(
      String productId, String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/can-review/$productId/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['canReview'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
