class AppUser {
  final String id;
  final String name;
  final String businessName;
  final String email;

  AppUser({
    required this.id,
    required this.name,
    required this.businessName,
    required this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      businessName: json['businessName'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'businessName': businessName,
        'email': email,
      };
}
