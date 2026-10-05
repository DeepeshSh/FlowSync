class Party {
  final String id;
  final String name;
  final String businessName;
  final String type; // 'SUPPLIER', 'CUSTOMER', 'DEALER'
  final String phone;
  final String email;
  final String gstin;
  final String address;
  final double currentBalance; // Positive: Receivable (Customer owes us), Negative: Payable (We owe supplier)
  final double creditLimit;
  final DateTime? createdAt;

  Party({
    required this.id,
    required this.name,
    required this.businessName,
    required this.type,
    required this.phone,
    this.email = '',
    this.gstin = '',
    this.address = '',
    this.currentBalance = 0.0,
    this.creditLimit = 0.0,
    this.createdAt,
  });

  bool get isSupplier => type.toUpperCase() == 'SUPPLIER';
  bool get isCustomer => type.toUpperCase() == 'CUSTOMER';
  bool get isDealer => type.toUpperCase() == 'DEALER';

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      businessName: json['businessName']?.toString() ?? '',
      type: json['type']?.toString().toUpperCase() ?? 'CUSTOMER',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      gstin: json['gstin']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'businessName': businessName,
      'type': type.toUpperCase(),
      'phone': phone,
      if (email.isNotEmpty) 'email': email,
      if (gstin.isNotEmpty) 'gstin': gstin,
      if (address.isNotEmpty) 'address': address,
      'currentBalance': currentBalance,
      'creditLimit': creditLimit,
    };
  }

  Party copyWith({
    String? id,
    String? name,
    String? businessName,
    String? type,
    String? phone,
    String? email,
    String? gstin,
    String? address,
    double? currentBalance,
    double? creditLimit,
    DateTime? createdAt,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      currentBalance: currentBalance ?? this.currentBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
