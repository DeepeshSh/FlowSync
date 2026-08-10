class Product {
  final String id;
  final String name;
  final String sku;
  final String brandName;
  final String categoryName;
   String warehouseId;
   String storageLocation;
  final String unit;
   int stock;
  final int lowStockThreshold;
  double purchasePrice;
  double sellingPrice;
  final String hsnCode;
  final String barcode;
  final String description;
  final double length;
  final double width;
  final double height;
  final String dimensionUnit;
  final bool fragile;
  final double gstPercentage;
  final double mrp;
  final String supplierName;
  final double amountPaid;
  final double outstandingBalance;
  final String purchaseDate;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.brandName,
    required this.categoryName,
    required this.storageLocation,
    required this.unit,
    required this.stock,
    required this.lowStockThreshold,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.imageUrl,
    this.warehouseId = "",
    this.hsnCode = "",
    this.barcode = "",
    this.description = "",
    this.length = 0.0,
    this.width = 0.0,
    this.height = 0.0,
    this.dimensionUnit = "cm",
    this.fragile = false,
    this.gstPercentage = 0.0,
    this.mrp = 0.0,
    this.supplierName = "",
    this.amountPaid = 0.0,
    this.outstandingBalance = 0.0,
    this.purchaseDate = "",
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val, {int defaultValue = 0}) {
      if (val == null) return defaultValue;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultValue;
      return defaultValue;
    }

    final dimensions = json["dimensions"] is Map<String, dynamic>
        ? json["dimensions"] as Map<String, dynamic>
        : {};

    return Product(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      sku: json["sku"]?.toString() ?? "",
      brandName: json["brandName"]?.toString() ?? json["brand"]?.toString() ?? "",
      categoryName: json["category"] != null
          ? (json["category"] is Map
              ? json["category"]["name"]?.toString() ?? ""
              : json["category"].toString())
          : "",
      warehouseId: json["warehouseId"]?.toString() ?? "",
      storageLocation: json["storageLocation"]?.toString() ?? json["rack"]?.toString() ?? "",
      unit: json["unit"]?.toString() ?? "pcs",
      stock: parseInt(json["stock"]),
      lowStockThreshold: parseInt(json["lowStockThreshold"], defaultValue: 10),
      purchasePrice: parseDouble(json["purchasePrice"] ?? json["buy_price"]),
      sellingPrice: parseDouble(json["sellingPrice"] ?? json["sell_price"]),
      hsnCode: json["hsnCode"]?.toString() ?? "",
      barcode: json["barcode"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      length: parseDouble(dimensions["length"]),
      width: parseDouble(dimensions["width"]),
      height: parseDouble(dimensions["height"]),
      dimensionUnit: dimensions["unit"]?.toString() ?? "cm",
      fragile: json["fragile"] == true,
      gstPercentage: parseDouble(json["gstPercentage"]),
      mrp: parseDouble(json["mrp"]),
      supplierName: json["supplierName"]?.toString() ?? "",
      amountPaid: parseDouble(json["amountPaid"]),
      outstandingBalance: parseDouble(json["outstandingBalance"]),
      purchaseDate: json["purchaseDate"]?.toString() ?? "",
      imageUrl: json["imageUrl"]?.toString() ?? json["image_url"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "sku": sku,
      "brandName": brandName,
      "category": categoryName,
      "warehouseId": warehouseId,
      "storageLocation": storageLocation,
      "unit": unit,
      "stock": stock,
      "lowStockThreshold": lowStockThreshold,
      "purchasePrice": purchasePrice,
      "sellingPrice": sellingPrice,
      "hsnCode": hsnCode,
      "barcode": barcode,
      "description": description,
      "dimensions": {
        "length": length,
        "width": width,
        "height": height,
        "unit": dimensionUnit,
      },
      "fragile": fragile,
      "gstPercentage": gstPercentage,
      "mrp": mrp,
      "supplierName": supplierName,
      "amountPaid": amountPaid,
      "outstandingBalance": outstandingBalance,
      "purchaseDate": purchaseDate,
      "imageUrl": imageUrl,
      "isActive": true,
      "hasVariants": false,
    };
  }
}