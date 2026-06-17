class Sale {
  final String id;

  final String saleNumber;

  final String customerName;

  final double totalAmount;

  final String paymentStatus;

  final DateTime saleDate;

  final int itemCount;

  Sale({
    required this.id,
    required this.saleNumber,
    required this.customerName,
    required this.totalAmount,
    required this.paymentStatus,
    required this.saleDate,
    required this.itemCount,
  });

  factory Sale.fromJson(
    Map<String, dynamic> json,
  ) {
    return Sale(
      id: json["_id"] ?? "",

      saleNumber:
          json["saleNumber"] ?? "",

      customerName:
          json["customerName"] ?? "",

      totalAmount:
          (json["totalAmount"] ?? 0)
              .toDouble(),

      paymentStatus:
          json["paymentStatus"] ??
              "Pending",

      saleDate:
          json["saleDate"] != null
              ? DateTime.parse(
                  json["saleDate"],
                )
              : DateTime.now(),

      itemCount:
          json["items"] != null
              ? json["items"].length
              : 0,
    );
  }
}