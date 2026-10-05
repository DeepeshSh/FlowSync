class AppUser {
  final String id;
  final String name;
  final String businessName;
  final String email;
  final String phone;
  final String gstin;
  final String address;

  AppUser({
    required this.id,
    required this.name,
    required this.businessName,
    required this.email,
    this.phone = '',
    this.gstin = '',
    this.address = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      businessName: json['businessName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gstin: json['gstin'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'businessName': businessName,
        'email': email,
        'phone': phone,
        'gstin': gstin,
        'address': address,
      };
}
