class Supplier {
  final String id;

  final String supplierName;
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

  factory Supplier.fromJson(
    Map<String, dynamic> json,
  ) {
    return Supplier(
      id: json["_id"] ?? "",

      supplierName:
          json["supplierName"] ?? "",

      contactPerson:
          json["contactPerson"] ?? "",

      phone:
          json["phone"] ?? "",

      email:
          json["email"] ?? "",

      gstNumber:
          json["gstNumber"] ?? "",

      address:
          json["address"] ?? "",

      city:
          json["city"] ?? "",

      state:
          json["state"] ?? "",

      pincode:
          json["pincode"] ?? "",

      paymentTerms:
          json["paymentTerms"] ?? "",

      openingBalance:
          (json["openingBalance"] ?? 0)
              .toDouble(),

      isActive:
          json["isActive"] ?? true,
    );
  }
}