class SalesInvoiceData {
  final String invoiceNumber;

  final DateTime saleDate;

  final InvoiceParty customer;

  final String paymentStatus;

  final List<SalesInvoiceItem> items;

  final double subtotal;

  final double gstAmount;

  final double transportCost;

  final double advanceReceived;

  final double grandTotal;

  final double balanceDue;

  final String notes;

  SalesInvoiceData({
    required this.invoiceNumber,
    required this.saleDate,
    required this.customer,
    required this.paymentStatus,
    required this.items,
    required this.subtotal,
    required this.gstAmount,
    required this.transportCost,
    required this.advanceReceived,
    required this.grandTotal,
    required this.balanceDue,
    required this.notes,
  });

  factory SalesInvoiceData.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalesInvoiceData(
      invoiceNumber:
          json["invoiceNumber"] ?? "",

      saleDate: DateTime.parse(
        json["saleDate"],
      ),

      customer: InvoiceParty.fromJson(
        json["customer"] ?? {},
      ),

      paymentStatus:
          json["paymentStatus"] ?? "Pending",

      items:
          (json["items"] as List? ?? [])
              .map(
                (e) =>
                    SalesInvoiceItem.fromJson(e),
              )
              .toList(),

      subtotal:
          (json["subtotal"] ?? 0)
              .toDouble(),

      gstAmount:
          (json["gstAmount"] ?? 0)
              .toDouble(),

      transportCost:
          (json["transportCost"] ?? 0)
              .toDouble(),

      advanceReceived:
          (json["advanceReceived"] ?? 0)
              .toDouble(),

      grandTotal:
          (json["grandTotal"] ?? 0)
              .toDouble(),

      balanceDue:
          (json["balanceDue"] ?? 0)
              .toDouble(),

      notes:
          json["notes"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "invoiceNumber":
          invoiceNumber,
      "saleDate":
          saleDate.toIso8601String(),
      "customer":
          customer.toJson(),
      "paymentStatus":
          paymentStatus,
      "items":
          items
              .map(
                (e) => e.toJson(),
              )
              .toList(),
      "subtotal":
          subtotal,
      "gstAmount":
          gstAmount,
      "transportCost":
          transportCost,
      "advanceReceived":
          advanceReceived,
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

class SalesInvoiceItem {
  final String productName;

  final String variantName;

  final int quantity;

  final double rate;

  final double total;

  final String productNote;

  SalesInvoiceItem({
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.rate,
    required this.total,
    required this.productNote,
  });

  factory SalesInvoiceItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalesInvoiceItem(
      productName:
          json["productName"] ?? "",

      variantName:
          json["variantName"] ?? "",

      quantity:
          json["quantity"] ?? 0,

      rate:
          (json["rate"] ?? 0)
              .toDouble(),

      total:
          (json["total"] ?? 0)
              .toDouble(),

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