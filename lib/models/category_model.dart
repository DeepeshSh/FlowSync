class Category {
  final String id;
  final String name;
  final String? parentCategoryId;
  final String unit;
  final bool isFragile;
  final bool isReturnable;
  final String notes;

  Category({
    required this.id,
    required this.name,
    this.parentCategoryId,
    required this.unit,
    required this.isFragile,
    required this.isReturnable,
    required this.notes,
  });

  factory Category.fromJson(
      Map<String, dynamic> json) {
    return Category(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      parentCategoryId:
          json["parentCategoryId"],
      unit: json["unit"] ?? "",
      isFragile:
          json["isFragile"] ?? false,
      isReturnable:
          json["isReturnable"] ?? false,
      notes: json["notes"] ?? "",
    );
  }
}