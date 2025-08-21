class Review {
  String? sId;
  String? userId;
  String? productId;
  double? rating;
  String? comment;
  String? title;
  List<String>? images;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isVerifiedPurchase;
  int? helpfulCount;
  UserInfo? user;

  Review({
    this.sId,
    this.userId,
    this.productId,
    this.rating,
    this.comment,
    this.title,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.isVerifiedPurchase,
    this.helpfulCount,
    this.user,
  });

  Review.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    productId = json['productId'];
    rating = json['rating']?.toDouble();
    comment = json['comment'];
    title = json['title'];
    images = json['images']?.cast<String>();
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    isVerifiedPurchase = json['isVerifiedPurchase'];
    helpfulCount = json['helpfulCount'];
    user = json['user'] != null ? UserInfo.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['productId'] = productId;
    data['rating'] = rating;
    data['comment'] = comment;
    data['title'] = title;
    data['images'] = images;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    data['isVerifiedPurchase'] = isVerifiedPurchase;
    data['helpfulCount'] = helpfulCount;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class UserInfo {
  String? sId;
  String? name;
  String? email;
  String? avatar;

  // Getter for id to maintain consistency
  String? get id => sId;

  UserInfo({
    this.sId,
    this.name,
    this.email,
    this.avatar,
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['avatar'] = avatar;
    return data;
  }
}

class ProductRating {
  double? averageRating;
  int? totalReviews;
  Map<int, int>? ratingDistribution;

  ProductRating({
    this.averageRating,
    this.totalReviews,
    this.ratingDistribution,
  });

  ProductRating.fromJson(Map<String, dynamic> json) {
    averageRating = json['averageRating']?.toDouble();
    totalReviews = json['totalReviews'];
    if (json['ratingDistribution'] != null) {
      ratingDistribution = (json['ratingDistribution'] as Map)
          .map((key, value) => MapEntry(int.parse(key.toString()), value));
    } else {
      ratingDistribution = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['averageRating'] = averageRating;
    data['totalReviews'] = totalReviews;
    data['ratingDistribution'] = ratingDistribution;
    return data;
  }
}
