class Purchase {
  final String id;
  final String purchaseNumber;
  final String supplierName;

  final double totalAmount;

  final String paymentStatus;

  final DateTime purchaseDate;

  final int itemCount;

  Purchase({
    required this.id,
    required this.purchaseNumber,
    required this.supplierName,
    required this.totalAmount,
    required this.paymentStatus,
    required this.purchaseDate,
    required this.itemCount,
  });

  factory Purchase.fromJson(
    Map<String, dynamic> json,
  ) {
    return Purchase(
      id: json["_id"] ?? "",

      purchaseNumber:
          json["purchaseNumber"] ?? "",

      supplierName:
          json["supplierName"] ?? "",

      totalAmount:
          (json["totalAmount"] ?? 0)
              .toDouble(),

      paymentStatus:
          json["paymentStatus"] ??
              "Pending",

      purchaseDate:
    json["purchaseDate"] != null
        ? DateTime.parse(
            json["purchaseDate"],
          )
        : DateTime.now(),
      itemCount:
          json["items"] != null
              ? json["items"].length
              : 0,
    );
  }
}