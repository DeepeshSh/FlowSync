class PurchaseItem {

  String productId;
  String productName;
  String sku;

  String unit; // NEW

  int quantity;

  double rate;
  double amount;

  PurchaseItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.unit, // NEW
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  factory PurchaseItem.fromJson(
  Map<String, dynamic> json,
) {
  return PurchaseItem(
    productId: json["productId"] ?? "",
    productName: json["productName"] ?? "",
    sku: json["sku"] ?? "",

    unit: json["unit"] ?? "PCS",

    quantity: json["quantity"] ?? 0,

    rate: (json["rate"] ?? 0).toDouble(),

    amount: (json["amount"] ?? 0).toDouble(),
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
  };
}

  void calculateAmount() {
  amount = quantity * rate;
}
}