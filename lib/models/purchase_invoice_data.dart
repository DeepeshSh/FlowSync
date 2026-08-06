class PurchaseInvoiceData {
  final String invoiceNumber;

  final DateTime purchaseDate;

  final InvoiceParty supplier;

  final String paymentStatus;

  final List<PurchaseInvoiceItem> items;

  final double subtotal;

  final double gstAmount;

  final double transportCost;

  final double advancePaid;

  final double grandTotal;

  final double balanceDue;

  final String notes;

  PurchaseInvoiceData({
    required this.invoiceNumber,
    required this.purchaseDate,
    required this.supplier,
    required this.paymentStatus,
    required this.items,
    required this.subtotal,
    required this.gstAmount,
    required this.transportCost,
    required this.advancePaid,
    required this.grandTotal,
    required this.balanceDue,
    required this.notes,
  });

  factory PurchaseInvoiceData.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseInvoiceData(
      invoiceNumber:
          json["invoiceNumber"] ?? "",

      purchaseDate: DateTime.parse(
        json["purchaseDate"],
      ),

      supplier: InvoiceParty.fromJson(
        json["supplier"] ?? {},
      ),

      paymentStatus:
          json["paymentStatus"] ?? "Pending",

      items:
          (json["items"] as List? ?? [])
              .map(
                (e) => PurchaseInvoiceItem.fromJson(e),
              )
              .toList(),

      subtotal:
          (json["subtotal"] ?? 0).toDouble(),

      gstAmount:
          (json["gstAmount"] ?? 0).toDouble(),

      transportCost:
          (json["transportCost"] ?? 0).toDouble(),

      advancePaid:
          (json["advancePaid"] ?? 0).toDouble(),

      grandTotal:
          (json["grandTotal"] ?? 0).toDouble(),

      balanceDue:
          (json["balanceDue"] ?? 0).toDouble(),

      notes:
          json["notes"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "invoiceNumber": invoiceNumber,
      "purchaseDate":
          purchaseDate.toIso8601String(),
      "supplier":
          supplier.toJson(),
      "paymentStatus":
          paymentStatus,
      "items":
          items
              .map((e) => e.toJson())
              .toList(),
      "subtotal":
          subtotal,
      "gstAmount":
          gstAmount,
      "transportCost":
          transportCost,
      "advancePaid":
          advancePaid,
      "grandTotal":
          grandTotal,
      "balanceDue":
          balanceDue,
      "notes":
          notes,
    };
  }
}

class InvoiceParty {
  final String name;

  final String phone;

  final String address;

  final String email;

  final String gstNumber;

  InvoiceParty({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.gstNumber,
  });

  factory InvoiceParty.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvoiceParty(
      name:
          json["name"] ?? "",

      phone:
          json["phone"] ?? "",

      address:
          json["address"] ?? "",

      email:
          json["email"] ?? "",

      gstNumber:
          json["gstNumber"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
      "address": address,
      "email": email,
      "gstNumber": gstNumber,
    };
  }
}

class PurchaseInvoiceItem {
  final String productName;

  final String variantName;

  final int quantity;

  final double rate;

  final double total;

  final String productNote;

  PurchaseInvoiceItem({
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.rate,
    required this.total,
    required this.productNote,
  });

  factory PurchaseInvoiceItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseInvoiceItem(
      productName:
          json["productName"] ?? "",

      variantName:
          json["variantName"] ?? "",

      quantity:
          json["quantity"] ?? 0,

      rate:
          (json["rate"] ?? 0).toDouble(),

      total:
          (json["total"] ?? 0).toDouble(),

      productNote:
          json["productNote"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productName":
          productName,
      "variantName":
          variantName,
      "quantity":
          quantity,
      "rate":
          rate,
      "total":
          total,
      "productNote":
          productNote,
    };
  }
}