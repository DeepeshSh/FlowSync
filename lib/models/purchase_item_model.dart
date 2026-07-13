class PurchaseItem {
  String productId;
  String productName;
  String sku;
  String unit;
  int quantity;
  double rate;
  double amount;
  String? notes; // FIXED: Added to match line-item notes in UI and Backend Schema

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
      productId: json["productId"] ?? "",
      productName: json["productName"] ?? "",
      sku: json["sku"] ?? "",
      unit: json["unit"] ?? "Pcs",
      quantity: json["quantity"] ?? 0,
      // FIXED: Enhanced type safety parsing for numeric floating data types
      rate: (json["rate"] as num?)?.toDouble() ?? 0.0,
      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
      notes: json["notes"],
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