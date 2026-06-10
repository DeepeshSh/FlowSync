import 'purchase_item_model.dart';

class Purchase {

  final String id;

  final String purchaseNumber;

  final String supplierId;

  final String supplierName;

  final String contactPerson;

  final String phone;

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

  factory Purchase.fromJson(
    Map<String, dynamic> json,
  ) {
    return Purchase(
      id:
          json["_id"] ?? "",

      purchaseNumber:
          json["purchaseNumber"] ?? "",

      supplierId:
          json["supplierId"] ?? "",

      supplierName:
          json["supplierName"] ?? "",

      contactPerson:
          json["contactPerson"] ?? "",

      phone:
          json["phone"] ?? "",

      paymentTerms:
          json["paymentTerms"] ?? "",

      purchaseDate:
          json["purchaseDate"] != null
              ? DateTime.parse(
                  json["purchaseDate"],
                )
              : DateTime.now(),

      deliveryDate:
          json["deliveryDate"] != null
              ? DateTime.parse(
                  json["deliveryDate"],
                )
              : null,

      items:
          json["items"] != null
              ? (json["items"] as List)
                  .map(
                    (e) =>
                        PurchaseItem
                            .fromJson(
                      e,
                    ),
                  )
                  .toList()
              : [],

      notes:
          json["notes"] ?? "",

      subtotal:
          (json["subtotal"] ?? 0)
              .toDouble(),

      discount:
          (json["discount"] ?? 0)
              .toDouble(),

      gst:
          (json["gst"] ?? 0)
              .toDouble(),

      transportCharges:
          (json["transportCharges"] ?? 0)
              .toDouble(),

      advancePayment:
          (json["advancePayment"] ?? 0)
              .toDouble(),

      balanceDue:
          (json["balanceDue"] ?? 0)
              .toDouble(),

      totalAmount:
          (json["totalAmount"] ?? 0)
              .toDouble(),

      paymentStatus:
          json["paymentStatus"] ??
              "Pending",

      status:
          json["status"] ??
              "Draft",
    );
  }
}