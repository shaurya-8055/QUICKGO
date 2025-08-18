class ServiceRequest {
  String? sId;
  String? userID;
  String? category;
  String? customerName;
  String? phone;
  String? address;
  String? description;
  String? preferredDate;
  String? preferredTime;
  String? status;
  String? assigneeId;
  String? assigneeName;
  String? assigneePhone;
  String? notes;
  String? createdAt;
  String? updatedAt;

  ServiceRequest({
    this.sId,
    this.userID,
    this.category,
    this.customerName,
    this.phone,
    this.address,
    this.description,
    this.preferredDate,
    this.preferredTime,
    this.status,
    this.assigneeId,
  this.assigneeName,
  this.assigneePhone,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  ServiceRequest.fromJson(Map<String, dynamic> json) {
    sId = json['_id']?.toString();
    userID = json['userID']?.toString();
    category = json['category']?.toString();
    customerName = json['customerName']?.toString();
    phone = json['phone']?.toString();
    address = json['address']?.toString();
    description = json['description']?.toString();
    preferredDate = json['preferredDate']?.toString();
    preferredTime = json['preferredTime']?.toString();
    status = json['status']?.toString();
    assigneeId = json['assigneeId']?.toString();
  assigneeName = json['assigneeName']?.toString();
  assigneePhone = json['assigneePhone']?.toString();
    notes = json['notes']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userID'] = userID;
    data['category'] = category;
    data['customerName'] = customerName;
    data['phone'] = phone;
    data['address'] = address;
    data['description'] = description;
    data['preferredDate'] = preferredDate;
    data['preferredTime'] = preferredTime;
    data['status'] = status;
    data['assigneeId'] = assigneeId;
  data['assigneeName'] = assigneeName;
  data['assigneePhone'] = assigneePhone;
    data['notes'] = notes;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
