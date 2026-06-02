class Product {
  final String id;
  final String name;
  final String sku;
  final int stock;
  final double purchasePrice;
  final double sellingPrice;
  final String categoryName;

  Product({
  required this.id,
  required this.name,
  required this.sku,
  required this.stock,
  required this.purchasePrice,
  required this.sellingPrice,
  required this.categoryName,
});

 factory Product.fromJson(
    Map<String, dynamic> json) {

  return Product(

    id: json["_id"] ?? "",

    name: json["name"] ?? "",

    sku: json["sku"] ?? "",

    stock: json["stock"] ?? 0,

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
  );
}
}