import '/models/purchase_model.dart';
import '/models/sale_model.dart';


class InvoiceData {
  final String invoiceNumber;

  final DateTime invoiceDate;

  /// Purchase Invoice / Sales Invoice
  final String invoiceTitle;

  /// Supplier Details / Customer Details
  final String partyTitle;

  /// Advance Paid / Advance Received
  final String advanceTitle;

  final InvoiceParty party;

  final String paymentStatus;

  final List<InvoiceItem> items;

  final double subtotal;

  final double gstAmount;

  final double transportCost;

  final double discount;

  final double advanceAmount;

  final double grandTotal;

  final double balanceDue;

  final String notes;

  InvoiceData({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceTitle,
    required this.partyTitle,
    required this.advanceTitle,
    required this.party,
    required this.paymentStatus,
    required this.items,
    required this.subtotal,
    required this.gstAmount,
    required this.transportCost,
    this.discount = 0,
    required this.advanceAmount,
    required this.grandTotal,
    required this.balanceDue,
    this.notes = "",
  });

  factory InvoiceData.fromPurchase(
  Purchase purchase,
) {
  return InvoiceData(
    invoiceNumber: purchase.purchaseNumber,

    invoiceDate: purchase.purchaseDate,

    invoiceTitle: "Purchase Invoice",

    partyTitle: "Supplier Details",

    advanceTitle: "Advance Paid",

    party: InvoiceParty(
  name: purchase.supplierName,
  phone: purchase.phone,
  address:
      "${purchase.address}, ${purchase.city}, ${purchase.state} - ${purchase.pincode}",
  email: purchase.email,
  gstNumber: purchase.gstNumber,
),

    paymentStatus: purchase.paymentStatus,

    items: purchase.items
        .map(
          (item) => InvoiceItem(
            productName: item.productName,
            variantName: "",
            quantity: item.quantity,
            rate: item.rate,
            total: item.amount,
           productNote: item.notes ?? "",
          ),
        )
        .toList(),

    subtotal: purchase.subtotal,

    gstAmount: purchase.gst,

    transportCost: purchase.transportCharges,

    discount: purchase.discount,

    advanceAmount: purchase.advancePayment,

    grandTotal: purchase.totalAmount,

    balanceDue: purchase.balanceDue,

    notes: purchase.notes,
  );
}

factory InvoiceData.fromSale(
  Sale sale,
) {
  return InvoiceData(
    invoiceNumber: sale.saleNumber,

    invoiceDate: sale.saleDate,

    invoiceTitle: "Sales Invoice",

    partyTitle: "Customer Details",

    advanceTitle: "Advance Received",

    party: InvoiceParty(
  name: sale.customerName,
  phone: sale.phone,
  address:
      "${sale.address}, ${sale.city}, ${sale.state} - ${sale.pincode}",
  email: sale.email,
  gstNumber: sale.gstNumber,
),

    paymentStatus: sale.paymentStatus,

    items: sale.items
        .map(
          (item) => InvoiceItem(
            productName: item.productName,
            variantName: "",
            quantity: item.quantity,
            rate: item.sellingPrice,
            total: item.total,
            productNote: item.notes,
          ),
        )
        .toList(),

    subtotal: sale.subtotal,

gstAmount: sale.gst,

transportCost: sale.transportCharges,

discount: sale.discount,

advanceAmount: sale.advancePayment,

grandTotal: sale.totalAmount,

balanceDue: sale.balanceDue,

notes: sale.notes,
  );
}

  factory InvoiceData.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvoiceData(
      invoiceNumber:
          json["invoiceNumber"] ?? "",

      invoiceDate: DateTime.parse(
        json["invoiceDate"],
      ),

      invoiceTitle:
          json["invoiceTitle"] ?? "",

      partyTitle:
          json["partyTitle"] ?? "",

      advanceTitle:
          json["advanceTitle"] ?? "",

      party: InvoiceParty.fromJson(
        json["party"] ?? {},
      ),

      paymentStatus:
          json["paymentStatus"] ?? "Pending",

      items:
          (json["items"] as List? ?? [])
              .map(
                (e) =>
                    InvoiceItem.fromJson(e),
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

      discount:
          (json["discount"] ?? 0)
              .toDouble(),

      advanceAmount:
          (json["advanceAmount"] ?? 0)
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
      "invoiceNumber": invoiceNumber,
      "invoiceDate":
          invoiceDate.toIso8601String(),
      "invoiceTitle":
          invoiceTitle,
      "partyTitle":
          partyTitle,
      "advanceTitle":
          advanceTitle,
      "party":
          party.toJson(),
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
      "discount":
          discount,
      "advanceAmount":
          advanceAmount,
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
    this.phone = "",
    this.address = "",
    this.email = "",
    this.gstNumber = "",
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

class InvoiceItem {
  final String productName;

  final String variantName;

  final int quantity;

  final double rate;

  final double total;

  final String productNote;

  InvoiceItem({
    required this.productName,
    this.variantName = "",
    required this.quantity,
    required this.rate,
    required this.total,
    this.productNote = "",
  });

  factory InvoiceItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvoiceItem(
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