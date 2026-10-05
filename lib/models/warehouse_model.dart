class Warehouse {
  final String id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String contactPerson;
  final String phone;
  final bool isActive;
  final String notes;
  final String warehouseType;
  
  // Analytics fields matching your UI counters
  final int productsCount;
  final double stockValue;
  final int totalStockUnits;
  final int lowStockItems;

  Warehouse({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.contactPerson,
    required this.phone,
    required this.isActive,
    required this.notes,
    required this.warehouseType,
    required this.productsCount,
    required this.stockValue,
    required this.totalStockUnits,
    required this.lowStockItems,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      // Checks both "_id" and "id" safely
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      code: json["code"]?.toString() ?? "",
      address: json["address"]?.toString() ?? "",
      city: json["city"]?.toString() ?? "",
      contactPerson: json["contactPerson"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      isActive: json["isActive"] ?? true,
      notes: json["notes"]?.toString() ?? "",
      warehouseType: json["warehouseType"]?.toString() ?? "Secondary",
      
      // Dynamic fallback updates for dashboard analytics
      productsCount: (json["productsCount"] is num) ? json["productsCount"].toInt() : 0,
      stockValue: (json["stockValue"] is num) ? (json["stockValue"] as num).toDouble() : 0.0,
      totalStockUnits: (json["totalStockUnits"] is num) ? json["totalStockUnits"].toInt() : 0,
      lowStockItems: (json["lowStockItems"] is num) ? json["lowStockItems"].toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "code": code,
      "address": address,
      "city": city,
      "contactPerson": contactPerson,
      "phone": phone,
      "isActive": isActive,
      "notes": notes,
      "warehouseType": warehouseType,
      "productsCount": productsCount,
      "stockValue": stockValue,
      "totalStockUnits": totalStockUnits,
      "lowStockItems": lowStockItems,
    };
  }
}