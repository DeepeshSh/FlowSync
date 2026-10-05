class InvoiceItem {
  final String productId;
  final String productName;
  final int quantity;
  final double rate;
  final double gstRate;
  final double amount;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.rate,
    this.gstRate = 18.0,
    required this.amount,
  });

  double get gstAmount => amount * (gstRate / 100);
  double get totalWithGst => amount + gstAmount;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 1;
    final r = (json['rate'] as num?)?.toDouble() ?? 0.0;
    final a = (json['amount'] as num?)?.toDouble() ?? (qty * r);

    return InvoiceItem(
      productId: json['productId'] is Map
          ? (json['productId']['_id']?.toString() ?? '')
          : (json['productId']?.toString() ?? ''),
      productName: json['productName']?.toString() ??
          (json['productId'] is Map ? json['productId']['name']?.toString() ?? 'Item' : 'Item'),
      quantity: qty,
      rate: r,
      gstRate: (json['gstRate'] as num?)?.toDouble() ?? 18.0,
      amount: a,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'rate': rate,
      'gstRate': gstRate,
      'amount': amount,
    };
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String type; // 'SALE', 'PURCHASE'
  final String partyId;
  final String partyName;
  final List<InvoiceItem> items;
  final double subtotal;
  final double gstTotal;
  final double grandTotal;
  final String paymentStatus; // 'PAID', 'UNPAID', 'PARTIAL'
  final String notes;
  final DateTime? date;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.partyId,
    required this.partyName,
    required this.items,
    required this.subtotal,
    required this.gstTotal,
    required this.grandTotal,
    this.paymentStatus = 'UNPAID',
    this.notes = '',
    this.date,
  });

  bool get isSale => type.toUpperCase() == 'SALE';
  bool get isPurchase => type.toUpperCase() == 'PURCHASE';
  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';
  bool get isUnpaid => paymentStatus.toUpperCase() == 'UNPAID';
  bool get isPartial => paymentStatus.toUpperCase() == 'PARTIAL';

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList = rawItems
        .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Invoice(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? 'INV-000000',
      type: json['type']?.toString().toUpperCase() ?? 'SALE',
      partyId: json['partyId'] is Map
          ? (json['partyId']['_id']?.toString() ?? '')
          : (json['partyId']?.toString() ?? ''),
      partyName: json['partyName']?.toString() ??
          (json['partyId'] is Map ? json['partyId']['businessName']?.toString() ?? 'Party' : 'Party'),
      items: itemsList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      gstTotal: (json['gstTotal'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus']?.toString().toUpperCase() ?? 'UNPAID',
      notes: json['notes']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceNumber': invoiceNumber,
      'type': type.toUpperCase(),
      'partyId': partyId,
      'partyName': partyName,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'gstTotal': gstTotal,
      'grandTotal': grandTotal,
      'paymentStatus': paymentStatus.toUpperCase(),
      'notes': notes,
      if (date != null) 'date': date!.toIso8601String(),
    };
  }
}
