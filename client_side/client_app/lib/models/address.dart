class Address {
  String phone;
  String street;
  String city;
  String state;
  String postalCode;
  String country;

  Address({
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        phone: json['phone'] ?? '',
        street: json['street'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        postalCode: json['postalCode'] ?? '',
        country: json['country'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'street': street,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
      };

  @override
  String toString() =>
      '$phone\n$street, $city, $state $postalCode, $country';
}
