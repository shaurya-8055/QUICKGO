class ServiceRequest {
  final String id;
  final String? userID;
  final String category;
  final String customerName;
  final String phone;
  final String address;
  final String? description;
  final DateTime preferredDate;
  final String preferredTime;
  final String
      status; // pending | approved | in-progress | completed | cancelled
  final String? assigneeId;
  final String? assigneeName;
  final String? assigneePhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceRequest({
    required this.id,
    this.userID,
    required this.category,
    required this.customerName,
    required this.phone,
    required this.address,
    this.description,
    required this.preferredDate,
    required this.preferredTime,
    required this.status,
    this.assigneeId,
    this.assigneeName,
    this.assigneePhone,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
        id: (json['id'] ?? json['_id']).toString(),
        userID: json['userID']?.toString(),
        category: json['category']?.toString() ?? '',
        customerName: json['customerName']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        description: json['description']?.toString(),
        preferredDate:
            DateTime.tryParse(json['preferredDate']?.toString() ?? '') ??
                DateTime.now(),
        preferredTime: json['preferredTime']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        assigneeId: json['assigneeId']?.toString(),
        assigneeName: json['assigneeName']?.toString(),
        assigneePhone: json['assigneePhone']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
      );
}
