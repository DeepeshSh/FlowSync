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
    String parseString(dynamic val, {String defaultKey = 'name'}) {
      if (val == null) return "";
      if (val is String) return val;
      if (val is Map) {
        return val[defaultKey]?.toString() ??
            val['supplierName']?.toString() ??
            val['name']?.toString() ??
            val['_id']?.toString() ??
            "";
      }
      return val.toString();
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    Map<String, dynamic>? supplierMap;
    if (json["supplierId"] is Map) {
      supplierMap = json["supplierId"] as Map<String, dynamic>;
    }

    final double parsedSubtotal = parseDouble(json["subtotal"]);
    final double parsedGst = parseDouble(json["gst"]);
    final double parsedTransport = parseDouble(json["transportCharges"]);
    final double parsedAdvance = parseDouble(json["advancePayment"]);
    final double parsedDue = parseDouble(json["balanceDue"]);

    // Calculate total amount if backend returns 0
    double rawTotal = parseDouble(json["totalAmount"]);
    if (rawTotal <= 0) {
      if (parsedDue > 0) {
        rawTotal = parsedDue + parsedAdvance;
      } else if (parsedSubtotal > 0) {
        rawTotal = parsedSubtotal + parsedGst + parsedTransport;
      }
    }

    // Extract paymentStatus
    String rawPaymentStatus = parseString(json["paymentStatus"]);
    if (rawPaymentStatus.isEmpty) {
      rawPaymentStatus = "Pending";
    }

    // Parse list of PurchaseItem
    List<PurchaseItem> parsedItems = [];
    if (json["items"] is List) {
      parsedItems = (json["items"] as List).map((e) {
        if (e is Map<String, dynamic>) {
          return PurchaseItem.fromJson(e);
        } else if (e is Map) {
          return PurchaseItem.fromJson(Map<String, dynamic>.from(e));
        }
        return PurchaseItem(
          productId: "",
          productName: "",
          sku: "",
          unit: "Pcs",
          quantity: 0,
          rate: 0.0,
          amount: 0.0,
        );
      }).toList();
    }

    return Purchase(
      id: parseString(json["_id"] ?? json["id"]),
      purchaseNumber: parseString(json["purchaseNumber"]),
      supplierId: parseString(json["supplierId"], defaultKey: '_id'),
      supplierName: parseString(
        json["supplierName"] ?? supplierMap?["supplierName"],
        defaultKey: 'supplierName',
      ),
      contactPerson: parseString(json["contactPerson"] ?? supplierMap?["contactPerson"]),
      phone: parseString(json["phone"] ?? supplierMap?["phone"]),
      email: parseString(json["email"] ?? supplierMap?["email"]),
      gstNumber: parseString(json["gstNumber"] ?? supplierMap?["gstNumber"]),
      address: parseString(json["address"] ?? supplierMap?["address"]),
      city: parseString(json["city"] ?? supplierMap?["city"]),
      state: parseString(json["state"] ?? supplierMap?["state"]),
      pincode: parseString(json["pincode"] ?? supplierMap?["pincode"]),
      paymentTerms: parseString(json["paymentTerms"]),
      purchaseDate: parseDate(json["purchaseDate"]),
      deliveryDate: parseNullableDate(json["deliveryDate"]),
      items: parsedItems,
      notes: parseString(json["notes"]),
      subtotal: parsedSubtotal,
      discount: parseDouble(json["discount"]),
      gst: parsedGst,
      transportCharges: parsedTransport,
      advancePayment: parsedAdvance,
      balanceDue: parsedDue,
      totalAmount: rawTotal,
      paymentStatus: rawPaymentStatus,
      status: parseString(json["status"]).isEmpty ? rawPaymentStatus : parseString(json["status"]),
    );
  }

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
      "items": items.map((item) => item.toJson()).toList(),
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