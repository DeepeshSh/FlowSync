class StatMetric {
  final double value;
  final double changePercent;

  StatMetric({required this.value, required this.changePercent});

  bool get isUp => changePercent >= 0;

  factory StatMetric.fromJson(
    Map<String, dynamic>? json, {
    String valueKey = 'amount',
  }) {
    final j = json ?? {};
    return StatMetric(
      value: (j[valueKey] as num?)?.toDouble() ?? 0,
      changePercent: (j['changePercent'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WarehouseAnalyticsData {
  final double stockValue;
  final double utilizationPercent;
  final int totalItems;
  final int avgStockAgeDays;

  WarehouseAnalyticsData({
    required this.stockValue,
    required this.utilizationPercent,
    required this.totalItems,
    required this.avgStockAgeDays,
  });

  factory WarehouseAnalyticsData.fromJson(Map<String, dynamic>? json) {
    final j = json ?? {};
    return WarehouseAnalyticsData(
      stockValue: (j['stockValue'] as num?)?.toDouble() ?? 0,
      utilizationPercent: (j['utilizationPercent'] as num?)?.toDouble() ?? 0,
      totalItems: (j['totalItems'] as num?)?.toInt() ?? 0,
      avgStockAgeDays: (j['avgStockAgeDays'] as num?)?.toInt() ?? 0,
    );
  }
}

class CategorySlice {
  final String label;
  final double percent;
  final int units;

  CategorySlice({required this.label, required this.percent, required this.units});

  factory CategorySlice.fromJson(Map<String, dynamic> json) {
    return CategorySlice(
      label: json['label'] ?? '',
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
      units: (json['units'] as num?)?.toInt() ?? 0,
    );
  }
}

class LowStockAlertItem {
  final String id;
  final String name;
  final String sku;
  final int stock;

  LowStockAlertItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.stock,
  });

  factory LowStockAlertItem.fromJson(Map<String, dynamic> json) {
    return LowStockAlertItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }
}

class RecentTxn {
  final String id;
  final String name;
  final double amount;
  final DateTime date;

  RecentTxn({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
  });

  factory RecentTxn.fromSaleJson(Map<String, dynamic> json) {
    return RecentTxn(
      id: json['saleNumber'] ?? '',
      name: json['customerName'] ?? '',
      amount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['saleDate'] ?? json['createdAt'] ?? '') ??
          DateTime.now(),
    );
  }

  factory RecentTxn.fromPurchaseJson(Map<String, dynamic> json) {
    return RecentTxn(
      id: json['purchaseNumber'] ?? '',
      name: json['supplierName'] ?? '',
      amount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(
              json['purchaseDate'] ?? json['createdAt'] ?? '') ??
          DateTime.now(),
    );
  }
}

class DashboardSummary {
  final StatMetric todaysSales;
  final StatMetric todaysPurchases;
  final StatMetric todaysOrders;
  final StatMetric pendingPayments;
  final WarehouseAnalyticsData warehouseAnalytics;
  final List<CategorySlice> categoryDistribution;
  final int totalStockUnits;
  final List<LowStockAlertItem> lowStockAlerts;
  final int lowStockCount;
  final int warehouseCount;
  final List<RecentTxn> recentSales;
  final List<RecentTxn> recentPurchases;

  DashboardSummary({
    required this.todaysSales,
    required this.todaysPurchases,
    required this.todaysOrders,
    required this.pendingPayments,
    required this.warehouseAnalytics,
    required this.categoryDistribution,
    required this.totalStockUnits,
    required this.lowStockAlerts,
    required this.lowStockCount,
    required this.warehouseCount,
    required this.recentSales,
    required this.recentPurchases,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      todaysSales: StatMetric.fromJson(json['todaysSales']),
      todaysPurchases: StatMetric.fromJson(json['todaysPurchases']),
      todaysOrders:
          StatMetric.fromJson(json['todaysOrders'], valueKey: 'count'),
      pendingPayments: StatMetric.fromJson(json['pendingPayments']),
      warehouseAnalytics:
          WarehouseAnalyticsData.fromJson(json['warehouseAnalytics']),
      categoryDistribution: (json['categoryDistribution'] as List? ?? [])
          .map((e) => CategorySlice.fromJson(e))
          .toList(),
      totalStockUnits: (json['totalStockUnits'] as num?)?.toInt() ?? 0,
      lowStockAlerts: (json['lowStockAlerts'] as List? ?? [])
          .map((e) => LowStockAlertItem.fromJson(e))
          .toList(),
      lowStockCount: (json['lowStockCount'] as num?)?.toInt() ?? 0,
      warehouseCount: (json['warehouseCount'] as num?)?.toInt() ?? 0,
      recentSales: (json['recentSales'] as List? ?? [])
          .map((e) => RecentTxn.fromSaleJson(e))
          .toList(),
      recentPurchases: (json['recentPurchases'] as List? ?? [])
          .map((e) => RecentTxn.fromPurchaseJson(e))
          .toList(),
    );
  }
}
