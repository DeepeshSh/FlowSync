import 'purchase_item_model.dart';

class Purchase {
  final String id;
  final String purchaseNumber;
  final String supplierId;
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
  final DateTime purchaseDate;
  final DateTime? deliveryDate;
  final List<PurchaseItem> items;
  final String notes;
  final double subtotal;
  final double discount;
  final double gst;
  final double transportCharges;
  final double advancePayment;
  final double balanceDue;
  final double totalAmount;
  final String paymentStatus;
  final String status;

  Purchase({
    required this.id,
    required this.purchaseNumber,
    required this.supplierId,
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
    required this.purchaseDate,
    required this.deliveryDate,
    required this.items,
    required this.notes,
    required this.subtotal,
    required this.discount,
    required this.gst,
    required this.transportCharges,
    required this.advancePayment,
    required this.balanceDue,
    required this.totalAmount,
    required this.paymentStatus,
    required this.status,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json["_id"] ?? json["id"] ?? "", // Fallback check if server sends id or _id
      purchaseNumber: json["purchaseNumber"] ?? "",
      supplierId: json["supplierId"] ?? "",
      supplierName: json["supplierName"] ?? "",
      contactPerson: json["contactPerson"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
gstNumber: json["gstNumber"] ?? "",
address: json["address"] ?? "",
city: json["city"] ?? "",
state: json["state"] ?? "",
pincode: json["pincode"] ?? "",
      paymentTerms: json["paymentTerms"] ?? "",
      purchaseDate: json["purchaseDate"] != null
          ? DateTime.parse(json["purchaseDate"])
          : DateTime.now(),
      deliveryDate: json["deliveryDate"] != null
          ? DateTime.parse(json["deliveryDate"])
          : null,
      items: json["items"] != null
          ? (json["items"] as List)
              .map((e) => PurchaseItem.fromJson(e))
              .toList()
          : [],
      notes: json["notes"] ?? "",
      subtotal: (json["subtotal"] as num?)?.toDouble() ?? 0.0,
      discount: (json["discount"] as num?)?.toDouble() ?? 0.0,
      gst: (json["gst"] as num?)?.toDouble() ?? 0.0,
      transportCharges: (json["transportCharges"] as num?)?.toDouble() ?? 0.0,
      advancePayment: (json["advancePayment"] as num?)?.toDouble() ?? 0.0,
      balanceDue: (json["balanceDue"] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json["totalAmount"] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json["paymentStatus"] ?? "Pending",
      status: json["status"] ?? "Draft",
    );
  }

  /// Converts the model instance back into a JSON Map representation 
  /// for easy payload integration with your PurchaseService POST/PUT calls.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) "_id": id,
      "purchaseNumber": purchaseNumber,
      "supplierId": supplierId,
      "supplierName": supplierName,
      "contactPerson": contactPerson,
      "phone": phone,
      "email": email,
"gstNumber": gstNumber,
"address": address,
"city": city,
"state": state,
"pincode": pincode,
      "paymentTerms": paymentTerms,
      "purchaseDate": purchaseDate.toIso8601String(),
      "deliveryDate": deliveryDate?.toIso8601String(),
      "items": items.map((item) => item.toJson()).toList(), // Make sure PurchaseItem also has toJson()
      "notes": notes,
      "subtotal": subtotal,
      "discount": discount,
      "gst": gst,
      "transportCharges": transportCharges,
      "advancePayment": advancePayment,
      "balanceDue": balanceDue,
      "totalAmount": totalAmount,
      "paymentStatus": paymentStatus,
      "status": status,
    };
  }
}