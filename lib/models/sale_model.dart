class Sale {
  final String id;

  // Sale Details
  final String saleNumber;
  final DateTime saleDate;

  // Customer Snapshot
  final String customerId;
  final String customerName;
  final String contactPerson;
  final String phone;
  final String email;
  final String gstNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;

  // Products
  final List<SaleItem> items;

  // Financials
  final double subtotal;
  final double discount;
  final double gst;
  final double transportCharges;
  final double advancePayment;
  final double balanceDue;
  final double totalAmount;

  // Notes
  final String notes;

  // Status
  final String paymentStatus;

  Sale({
    required this.id,
    required this.saleNumber,
    required this.saleDate,
    required this.customerId,
    required this.customerName,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.gstNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.gst,
    required this.transportCharges,
    required this.advancePayment,
    required this.balanceDue,
    required this.totalAmount,
    required this.notes,
    required this.paymentStatus,
  });

  factory Sale.fromJson(
    Map<String, dynamic> json,
  ) {
    return Sale(
      id: json["_id"] ?? "",

      saleNumber: json["saleNumber"] ?? "",

      saleDate: json["saleDate"] != null
          ? DateTime.parse(json["saleDate"])
          : DateTime.now(),

      customerId: json["customerId"]?.toString() ?? "",

      customerName: json["customerName"] ?? "",

      contactPerson: json["contactPerson"] ?? "",

      phone: json["phone"] ?? "",

      email: json["email"] ?? "",

      gstNumber: json["gstNumber"] ?? "",

      address: json["address"] ?? "",

      city: json["city"] ?? "",

      state: json["state"] ?? "",

      pincode: json["pincode"] ?? "",

      items: json["items"] != null
          ? (json["items"] as List)
              .map(
                (e) => SaleItem.fromJson(e),
              )
              .toList()
          : [],

      subtotal:
          (json["subtotal"] as num?)?.toDouble() ?? 0,

      discount:
          (json["discount"] as num?)?.toDouble() ?? 0,

      gst:
          (json["gst"] as num?)?.toDouble() ?? 0,

      transportCharges:
          (json["transportCharges"] as num?)
                  ?.toDouble() ??
              0,

      advancePayment:
          (json["advancePayment"] as num?)
                  ?.toDouble() ??
              0,

      balanceDue:
          (json["balanceDue"] as num?)
                  ?.toDouble() ??
              0,

      totalAmount:
          (json["totalAmount"] as num?)
                  ?.toDouble() ??
              0,

      notes: json["notes"] ?? "",

      paymentStatus:
          json["paymentStatus"] ?? "Pending",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,

      "saleNumber": saleNumber,

      "saleDate":
          saleDate.toIso8601String(),

      "customerId": customerId,

      "customerName": customerName,

      "contactPerson": contactPerson,

      "phone": phone,

      "email": email,

      "gstNumber": gstNumber,

      "address": address,

      "city": city,

      "state": state,

      "pincode": pincode,

      "items": items
          .map((e) => e.toJson())
          .toList(),

      "subtotal": subtotal,

      "discount": discount,

      "gst": gst,

      "transportCharges":
          transportCharges,

      "advancePayment":
          advancePayment,

      "balanceDue": balanceDue,

      "totalAmount": totalAmount,

      "notes": notes,

      "paymentStatus":
          paymentStatus,
    };
  }
}

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double sellingPrice;
  final double total;
  final String notes;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.sellingPrice,
    required this.total,
    this.notes = "",
  });

  factory SaleItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return SaleItem(
      productId:
          json["productId"] ?? "",

      productName:
          json["productName"] ?? "",

      quantity:
          json["quantity"] ?? 0,

      sellingPrice:
          (json["sellingPrice"] as num?)
                  ?.toDouble() ??
              0,

      total:
          (json["total"] as num?)
                  ?.toDouble() ??
              0,

      notes:
          json["notes"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "productName": productName,
      "quantity": quantity,
      "sellingPrice": sellingPrice,
      "total": total,
      "notes": notes,
    };
  }
}