class Customer {
  final String id;

  final String customerName;
  final String contactPerson;

  final String phone;
  final String email;

  final String gstNumber;

  final String address;
  final String city;
  final String state;
  final String pincode;

  final double creditLimit;
  final double openingBalance;

  final bool isActive;

  Customer({
    required this.id,
    required this.customerName,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.gstNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.creditLimit,
    required this.openingBalance,
    required this.isActive,
  });

  factory Customer.fromJson(
    Map<String, dynamic> json,
  ) {
    return Customer(
      id: json["_id"] ?? "",

      customerName:
          json["customerName"] ?? "",

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

      creditLimit:
          (json["creditLimit"] ?? 0)
              .toDouble(),

      openingBalance:
          (json["openingBalance"] ?? 0)
              .toDouble(),

      isActive:
          json["isActive"] ?? true,
    );
  }
}