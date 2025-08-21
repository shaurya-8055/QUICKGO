import '../models/review.dart';

class DummyReviewData {
  static List<Review> getReviewsForProduct(String productId) {
    return getDummyReviews();
  }

  static ProductRating getProductRating(String productId) {
    return getDummyProductRating();
  }

  static List<Review> getDummyReviews() {
    return [
      Review.fromJson({
        '_id': '1',
        'userId': 'user1',
        'productId': 'product1',
        'rating': 5.0,
        'title': 'Excellent product quality',
        'comment':
            'This product exceeded my expectations. The build quality is outstanding and it works exactly as described. I\'ve been using it for 3 months now and it\'s still perfect. Highly recommended for anyone looking for a reliable solution.',
        'images': [
          'https://picsum.photos/200/200?random=1',
          'https://picsum.photos/200/200?random=2',
        ],
        'createdAt': '2024-08-15T10:30:00Z',
        'isVerifiedPurchase': true,
        'helpfulCount': 24,
        'user': {
          '_id': 'user1',
          'name': 'Sarah Johnson',
          'email': 'sarah@example.com',
          'avatar': 'https://picsum.photos/40/40?random=10'
        }
      }),
      Review.fromJson({
        '_id': '2',
        'userId': 'user2',
        'productId': 'product1',
        'rating': 4.0,
        'title': 'Good value for money',
        'comment':
            'Overall satisfied with the purchase. The product does what it\'s supposed to do, though the packaging could be better. Delivery was quick and customer service was helpful when I had questions.',
        'images': [],
        'createdAt': '2024-08-10T14:20:00Z',
        'isVerifiedPurchase': true,
        'helpfulCount': 12,
        'user': {
          '_id': 'user2',
          'name': 'Mike Chen',
          'email': 'mike@example.com',
          'avatar': 'https://picsum.photos/40/40?random=11'
        }
      }),
      Review.fromJson({
        '_id': '3',
        'userId': 'user3',
        'productId': 'product1',
        'rating': 5.0,
        'title': 'Perfect for my needs',
        'comment':
            'Exactly what I was looking for! The features are well-designed and intuitive. Setup was straightforward and the documentation is clear.',
        'images': [
          'https://picsum.photos/200/200?random=3',
        ],
        'createdAt': '2024-08-08T09:15:00Z',
        'isVerifiedPurchase': true,
        'helpfulCount': 8,
        'user': {
          '_id': 'user3',
          'name': 'Emily Rodriguez',
          'email': 'emily@example.com',
          'avatar': 'https://picsum.photos/40/40?random=12'
        }
      }),
      Review.fromJson({
        '_id': '4',
        'userId': 'user4',
        'productId': 'product1',
        'rating': 3.0,
        'title': 'Average product',
        'comment':
            'It\'s okay but not amazing. Some features could be improved. The price point is reasonable though.',
        'images': [],
        'createdAt': '2024-08-05T16:45:00Z',
        'isVerifiedPurchase': false,
        'helpfulCount': 3,
        'user': {
          '_id': 'user4',
          'name': 'John Smith',
          'email': 'john@example.com',
          'avatar': 'https://picsum.photos/40/40?random=13'
        }
      }),
      Review.fromJson({
        '_id': '5',
        'userId': 'user5',
        'productId': 'product1',
        'rating': 5.0,
        'title': 'Outstanding experience',
        'comment':
            'From ordering to delivery, everything was smooth. The product quality is top-notch and the customer support team was incredibly helpful. Will definitely order again!',
        'images': [
          'https://picsum.photos/200/200?random=4',
          'https://picsum.photos/200/200?random=5',
          'https://picsum.photos/200/200?random=6',
        ],
        'createdAt': '2024-08-03T11:30:00Z',
        'isVerifiedPurchase': true,
        'helpfulCount': 31,
        'user': {
          '_id': 'user5',
          'name': 'Lisa Wang',
          'email': 'lisa@example.com',
          'avatar': 'https://picsum.photos/40/40?random=14'
        }
      }),
      Review.fromJson({
        '_id': '6',
        'userId': 'user6',
        'productId': 'product1',
        'rating': 4.0,
        'title': 'Solid choice',
        'comment':
            'Good product overall. Minor issues with the initial setup but customer service resolved them quickly.',
        'images': [],
        'createdAt': '2024-08-01T13:20:00Z',
        'isVerifiedPurchase': true,
        'helpfulCount': 7,
        'user': {
          '_id': 'user6',
          'name': 'David Brown',
          'email': 'david@example.com',
          'avatar': 'https://picsum.photos/40/40?random=15'
        }
      }),
      Review.fromJson({
        '_id': '7',
        'userId': 'user7',
        'productId': 'product1',
        'rating': 2.0,
        'title': 'Not as expected',
        'comment':
            'Product didn\'t meet my expectations. Quality feels cheaper than advertised. Considering returning it.',
        'images': [
          'https://picsum.photos/200/200?random=7',
        ],
        'createdAt': '2024-07-30T08:10:00Z',
        'isVerifiedPurchase': true,
        'helpfulCount': 5,
        'user': {
          '_id': 'user7',
          'name': 'Anna Taylor',
          'email': 'anna@example.com',
          'avatar': 'https://picsum.photos/40/40?random=16'
        }
      }),
      Review.fromJson({
        '_id': '8',
        'userId': 'user8',
        'productId': 'product1',
        'rating': 4.0,
        'title': 'Great features',
        'comment':
            'Love the innovative features and sleek design. A few minor bugs but nothing deal-breaking. Regular updates show the company cares about improvement.',
        'images': [],
        'createdAt': '2024-07-28T15:40:00Z',
        'isVerifiedPurchase': true,
        'helpfulCount': 15,
        'user': {
          '_id': 'user8',
          'name': 'Mark Wilson',
          'email': 'mark@example.com',
          'avatar': 'https://picsum.photos/40/40?random=17'
        }
      }),
    ];
  }

  static ProductRating getDummyProductRating() {
    return ProductRating.fromJson({
      'averageRating': 4.1,
      'totalReviews': 2431,
      'ratingDistribution': {'5': 1250, '4': 789, '3': 256, '2': 89, '1': 47}
    });
  }
}
