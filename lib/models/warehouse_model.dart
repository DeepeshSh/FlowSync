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
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      code: json["code"] ?? "",
      address: json["address"] ?? "",
      city: json["city"] ?? "",
      contactPerson: json["contactPerson"] ?? "",
      phone: json["phone"] ?? "",
      isActive: json["isActive"] ?? true,
      notes: json["notes"] ?? "",
      warehouseType: json["warehouseType"] ?? "Secondary",
      
      // Dynamic fallback updates for dashboard analytics
      productsCount: json["productsCount"] ?? 0,
      stockValue: (json["stockValue"] ?? 0).toDouble(),
      totalStockUnits: json["totalStockUnits"] ?? 0,
      lowStockItems: json["lowStockItems"] ?? 0,
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
      
      // Upstream synchronization keys
      "productsCount": productsCount,
      "stockValue": stockValue,
      "totalStockUnits": totalStockUnits,
      "lowStockItems": lowStockItems,
    };
  }
}