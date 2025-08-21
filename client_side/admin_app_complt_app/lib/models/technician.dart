class Technician {
  final String? sId;
  final String? name;
  final String? phone;
  final List<String>? skills;
  final bool? active;
  final String? createdAt;
  final String? updatedAt;

  Technician({
    this.sId,
    this.name,
    this.phone,
    this.skills,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory Technician.fromJson(Map<String, dynamic> json) => Technician(
        sId: json["_id"],
        name: json["name"],
        phone: json["phone"],
        skills:
            json["skills"] != null ? List<String>.from(json["skills"]) : null,
        active: json["active"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        "_id": sId,
        "name": name,
        "phone": phone,
        "skills": skills,
        "active": active,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };

  @override
  String toString() {
    return 'Technician(name: $name, phone: $phone, skills: $skills, active: $active)';
  }
}
