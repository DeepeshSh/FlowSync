class Variant {
  final String id;

  final String productId;

  final String variantName;

  final String sku;

  final String barcode;

  final String warehouseId;
  final String warehouseName;

  final String storageLocation;

  final int stock;
  final int reservedStock;
  final int availableStock;
  final int lowStockThreshold;

  final double purchasePrice;
  final double sellingPrice;
  final double mrp;
  final double gstPercentage;

  final String imageUrl;

  final bool isActive;

  Variant({
    required this.id,
    required this.productId,
    required this.variantName,
    required this.sku,
    required this.barcode,
    required this.warehouseId,
    required this.warehouseName,
    required this.storageLocation,
    required this.stock,
    required this.reservedStock,
    required this.availableStock,
    required this.lowStockThreshold,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.mrp,
    required this.gstPercentage,
    required this.imageUrl,
    required this.isActive,
  });

  factory Variant.fromJson(
    Map<String, dynamic> json,
  ) {
    return Variant(
      id: json["_id"] ?? "",

      productId:
          json["productId"] is Map
              ? json["productId"]["_id"] ?? ""
              : json["productId"] ?? "",

      variantName:
          json["variantName"] ?? "",

      sku: json["sku"] ?? "",

      barcode:
          json["barcode"] ?? "",

      warehouseId:
          json["warehouseId"] is Map
              ? json["warehouseId"]["_id"] ?? ""
              : json["warehouseId"] ?? "",

      warehouseName:
          json["warehouseId"] is Map
              ? json["warehouseId"]["name"] ?? ""
              : "",

      storageLocation:
          json["storageLocation"] ?? "",

      stock: json["stock"] ?? 0,

      reservedStock:
          json["reservedStock"] ?? 0,

      availableStock:
          json["availableStock"] ?? 0,

      lowStockThreshold:
          json["lowStockThreshold"] ?? 5,

      purchasePrice:
          (json["purchasePrice"] ?? 0)
              .toDouble(),

      sellingPrice:
          (json["sellingPrice"] ?? 0)
              .toDouble(),

      mrp:
          (json["mrp"] ?? 0)
              .toDouble(),

      gstPercentage:
          (json["gstPercentage"] ?? 0)
              .toDouble(),

      imageUrl:
          json["imageUrl"] ?? "",

      isActive:
          json["isActive"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "variantName": variantName,
      "sku": sku,
      "barcode": barcode,
      "warehouseId": warehouseId,
      "storageLocation": storageLocation,
      "stock": stock,
      "reservedStock": reservedStock,
      "availableStock": availableStock,
      "lowStockThreshold": lowStockThreshold,
      "purchasePrice": purchasePrice,
      "sellingPrice": sellingPrice,
      "mrp": mrp,
      "gstPercentage": gstPercentage,
      "imageUrl": imageUrl,
      "isActive": isActive,
    };
  }

  bool get isLowStock =>
      availableStock <= lowStockThreshold;
}