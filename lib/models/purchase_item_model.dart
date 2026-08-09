class PurchaseItem {
  String productId;
  String productName;
  String sku;
  String unit;
  int quantity;
  double rate;
  double amount;
  String? notes;

  PurchaseItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.unit,
    required this.quantity,
    required this.rate,
    required this.amount,
    this.notes,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      productId: json["productId"]?.toString() ?? "",
      productName: json["productName"]?.toString() ?? "",
      sku: json["sku"]?.toString() ?? "",
      unit: json["unit"]?.toString() ?? "Pcs",
      // FIXED: Safely convert double/num quantities to int to avoid TypeErrors
      quantity: (json["quantity"] as num?)?.toInt() ?? 0,
      rate: (json["rate"] as num?)?.toDouble() ?? 0.0,
      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
      notes: json["notes"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "productName": productName,
      "sku": sku,
      "unit": unit,
      "quantity": quantity,
      "rate": rate,
      "amount": amount,
      if (notes != null) "notes": notes,
    };
  }

  void calculateAmount() {
    amount = quantity * rate;
  }
}
