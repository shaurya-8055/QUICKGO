import 'dart:math' as math;

class Technician {
  final String id;
  final String name;
  final String phone;
  final List<String> skills;
  final bool active;
  final double? latitude;
  final double? longitude;
  final double rating; // Average rating (0.0 - 5.0)
  final int totalJobs; // Completed jobs count
  final int yearsExperience;
  final String? profileImage;
  final List<String>? certifications;
  final bool verified; // ID/background check verified
  final double? pricePerHour; // Base hourly rate
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? currentlyAvailable; // Real-time availability status

  Technician({
    required this.id,
    required this.name,
    required this.phone,
    required this.skills,
    required this.active,
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.totalJobs = 0,
    this.yearsExperience = 0,
    this.profileImage,
    this.certifications,
    this.verified = false,
    this.pricePerHour,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.currentlyAvailable,
  });

  factory Technician.fromJson(Map<String, dynamic> json) => Technician(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
        active: json['active'] ?? true,
        latitude: json['latitude'] != null
            ? double.tryParse(json['latitude'].toString())
            : null,
        longitude: json['longitude'] != null
            ? double.tryParse(json['longitude'].toString())
            : null,
        rating: json['rating'] != null
            ? double.tryParse(json['rating'].toString()) ?? 0.0
            : 0.0,
        totalJobs: json['totalJobs'] != null
            ? int.tryParse(json['totalJobs'].toString()) ?? 0
            : 0,
        yearsExperience: json['yearsExperience'] != null
            ? int.tryParse(json['yearsExperience'].toString()) ?? 0
            : 0,
        profileImage: json['profileImage']?.toString(),
        certifications: json['certifications'] != null
            ? List<String>.from(json['certifications'])
            : null,
        verified: json['verified'] ?? false,
        pricePerHour: json['pricePerHour'] != null
            ? double.tryParse(json['pricePerHour'].toString())
            : null,
        bio: json['bio']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
        currentlyAvailable: json['currentlyAvailable'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'phone': phone,
        'skills': skills,
        'active': active,
        'latitude': latitude,
        'longitude': longitude,
        'rating': rating,
        'totalJobs': totalJobs,
        'yearsExperience': yearsExperience,
        'profileImage': profileImage,
        'certifications': certifications,
        'verified': verified,
        'pricePerHour': pricePerHour,
        'bio': bio,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'currentlyAvailable': currentlyAvailable,
      };

  // Calculate distance from user location (in km)
  double? distanceFrom(double? userLat, double? userLon) {
    if (latitude == null ||
        longitude == null ||
        userLat == null ||
        userLon == null) {
      return null;
    }

    // Haversine formula for distance calculation
    const double earthRadius = 6371; // km
    final double dLat = _toRadians(userLat - latitude!);
    final double dLon = _toRadians(userLon - longitude!);

    final double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(latitude!)) *
            math.cos(_toRadians(userLat)) *
            math.pow(math.sin(dLon / 2), 2);

    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  @override
  String toString() {
    return 'Technician(id: $id, name: $name, skills: $skills, rating: $rating, verified: $verified)';
  }
}
