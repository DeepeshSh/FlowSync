class Supplier {
  final String id;
  final String supplierName;
  final String companyName; // 1. Added companyName field
  final String contactPerson;
  final String phone;
  final String email;
  final String gstNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String paymentTerms;
  final double openingBalance;
  final bool isActive;

  Supplier({
    required this.id,
    required this.supplierName,
    required this.companyName, // 1. Added to constructor
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.gstNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.paymentTerms,
    required this.openingBalance,
    required this.isActive,
  });

  // 2. Added getter to support screen references to 'supplier.name'
  String get name => supplierName;

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json["_id"] ?? "",
      supplierName: json["supplierName"] ?? "",
      companyName: json["companyName"] ?? "", // 1. Added fromJson mapping
      contactPerson: json["contactPerson"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      gstNumber: json["gstNumber"] ?? "",
      address: json["address"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      pincode: json["pincode"] ?? "",
      paymentTerms: json["paymentTerms"] ?? "",
      openingBalance: (json["openingBalance"] ?? 0).toDouble(),
      isActive: json["isActive"] ?? true,
    );
  }

  // Helper method to convert the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "supplierName": supplierName,
      "companyName": companyName,
      "contactPerson": contactPerson,
      "phone": phone,
      "email": email,
      "gstNumber": gstNumber,
      "address": address,
      "city": city,
      "state": state,
      "pincode": pincode,
      "paymentTerms": paymentTerms,
      "openingBalance": openingBalance,
      "isActive": isActive,
    };
  }
}