class Product {
  final String id;
  final String name;
  final String sku;

  final String brandName;
  final String unit;
  final String storageLocation;

  final int stock;
  final int lowStockThreshold;

  final double purchasePrice;
  final double sellingPrice;

  final String categoryName;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.sku,

    required this.brandName,
    required this.unit,
    required this.storageLocation,

    required this.stock,
    required this.lowStockThreshold,

    required this.purchasePrice,
    required this.sellingPrice,

    required this.categoryName,
    required this.imageUrl,
  });

  factory Product.fromJson(
    Map<String, dynamic> json,
  ) {
    return Product(
      id: json["_id"] ?? "",

      name: json["name"] ?? "",

      sku: json["sku"] ?? "",

      brandName:
          json["brandName"] ?? "",

      unit:
          json["unit"] ?? "pcs",

      storageLocation:
          json["storageLocation"] ?? "",

      stock:
          json["stock"] ?? 0,

      lowStockThreshold:
          json["lowStockThreshold"] ?? 10,

      purchasePrice:
          (json["purchasePrice"] ?? 0)
              .toDouble(),

      sellingPrice:
          (json["sellingPrice"] ?? 0)
              .toDouble(),

      categoryName:
          json["category"] != null
              ? json["category"]["name"] ?? ""
              : "",

      imageUrl:
          json["imageUrl"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "sku": sku,

      "brandName": brandName,

      "unit": unit,

      "storageLocation":
          storageLocation,

      "stock": stock,

      "lowStockThreshold":
          lowStockThreshold,

      "purchasePrice":
          purchasePrice,

      "sellingPrice":
          sellingPrice,

      "imageUrl": imageUrl,
    };
  }
}