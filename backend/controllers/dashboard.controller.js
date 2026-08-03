const Sale = require("../models/Sale");
const Purchase = require("../models/Purchase");
const Product = require("../models/Product");
const Warehouse = require("../models/warehouse");

// Percentage change helper. Returns a signed number, e.g. 18.6 or -6.7.
function percentChange(current, previous) {
  if (!previous) {
    return current > 0 ? 100 : 0;
  }
  return Math.round(((current - previous) / previous) * 1000) / 10;
}

function startOfDay(date) {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

// =============================
// GET DASHBOARD SUMMARY
// GET /api/dashboard/summary
// =============================
exports.getDashboardSummary = async (req, res) => {
  try {
    const now = new Date();
    const startToday = startOfDay(now);
    const startYesterday = new Date(startToday);
    startYesterday.setDate(startYesterday.getDate() - 1);
    const startLast7Days = new Date(startToday);
    startLast7Days.setDate(startLast7Days.getDate() - 7);
    const startPrev7Days = new Date(startToday);
    startPrev7Days.setDate(startPrev7Days.getDate() - 14);

    // ---------------------------------------------------
    // TODAY'S SALES + TODAY'S ORDERS (count of sales today)
    // ---------------------------------------------------
    const [todaySalesAgg] = await Sale.aggregate([
      { $match: { saleDate: { $gte: startToday } } },
      { $group: { _id: null, total: { $sum: "$totalAmount" }, count: { $sum: 1 } } },
    ]);
    const [yesterdaySalesAgg] = await Sale.aggregate([
      { $match: { saleDate: { $gte: startYesterday, $lt: startToday } } },
      { $group: { _id: null, total: { $sum: "$totalAmount" }, count: { $sum: 1 } } },
    ]);

    const todaySalesAmount = todaySalesAgg?.total || 0;
    const yesterdaySalesAmount = yesterdaySalesAgg?.total || 0;
    const todayOrdersCount = todaySalesAgg?.count || 0;
    const yesterdayOrdersCount = yesterdaySalesAgg?.count || 0;

    // ---------------------------------------------------
    // TODAY'S PURCHASES
    // ---------------------------------------------------
    const [todayPurchaseAgg] = await Purchase.aggregate([
      { $match: { purchaseDate: { $gte: startToday } } },
      { $group: { _id: null, total: { $sum: "$totalAmount" } } },
    ]);
    const [yesterdayPurchaseAgg] = await Purchase.aggregate([
      { $match: { purchaseDate: { $gte: startYesterday, $lt: startToday } } },
      { $group: { _id: null, total: { $sum: "$totalAmount" } } },
    ]);

    const todayPurchasesAmount = todayPurchaseAgg?.total || 0;
    const yesterdayPurchasesAmount = yesterdayPurchaseAgg?.total || 0;

    // ---------------------------------------------------
    // PENDING PAYMENTS
    // Total currently outstanding = unpaid sales (receivables) + unpaid
    // purchases (payables). Trend compares pending amounts created in the
    // last 7 days vs the 7 days before that (there is no historical
    // snapshot of "amount pending as of a past date", so this trend is a
    // proxy based on newly created pending transactions).
    // ---------------------------------------------------
    const [pendingSalesAgg] = await Sale.aggregate([
      { $match: { paymentStatus: { $ne: "Paid" } } },
      { $group: { _id: null, total: { $sum: "$totalAmount" } } },
    ]);
    const [pendingPurchasesAgg] = await Purchase.aggregate([
      { $match: { paymentStatus: { $ne: "Paid" } } },
      { $group: { _id: null, total: { $sum: "$balanceDue" } } },
    ]);

    const pendingPaymentsAmount =
      (pendingSalesAgg?.total || 0) + (pendingPurchasesAgg?.total || 0);

    const [pendingLast7Sales] = await Sale.aggregate([
      { $match: { paymentStatus: { $ne: "Paid" }, saleDate: { $gte: startLast7Days } } },
      { $group: { _id: null, total: { $sum: "$totalAmount" } } },
    ]);
    const [pendingLast7Purchases] = await Purchase.aggregate([
      { $match: { paymentStatus: { $ne: "Paid" }, purchaseDate: { $gte: startLast7Days } } },
      { $group: { _id: null, total: { $sum: "$balanceDue" } } },
    ]);
    const [pendingPrev7Sales] = await Sale.aggregate([
      { $match: { paymentStatus: { $ne: "Paid" }, saleDate: { $gte: startPrev7Days, $lt: startLast7Days } } },
      { $group: { _id: null, total: { $sum: "$totalAmount" } } },
    ]);
    const [pendingPrev7Purchases] = await Purchase.aggregate([
      { $match: { paymentStatus: { $ne: "Paid" }, purchaseDate: { $gte: startPrev7Days, $lt: startLast7Days } } },
      { $group: { _id: null, total: { $sum: "$balanceDue" } } },
    ]);

    const pendingLast7Total = (pendingLast7Sales?.total || 0) + (pendingLast7Purchases?.total || 0);
    const pendingPrev7Total = (pendingPrev7Sales?.total || 0) + (pendingPrev7Purchases?.total || 0);

    // ---------------------------------------------------
    // PRODUCTS / STOCK / CATEGORY DISTRIBUTION / LOW STOCK / STOCK AGE
    // ---------------------------------------------------
    const products = await Product.find({ isActive: true })
      .populate("category", "name")
      .lean();

    const totalProducts = products.length;
    let totalStockUnits = 0;
    let totalStockValue = 0;
    let totalAgeDays = 0;
    const categoryStockMap = {};

    products.forEach((p) => {
      const stock = p.stock || 0;
      totalStockUnits += stock;
      totalStockValue += stock * (p.sellingPrice || 0);

      const createdAt = p.createdAt ? new Date(p.createdAt) : now;
      totalAgeDays += (now - createdAt) / (1000 * 60 * 60 * 24);

      const catName = p.category?.name || "Uncategorized";
      categoryStockMap[catName] = (categoryStockMap[catName] || 0) + stock;
    });

    const avgStockAgeDays = totalProducts > 0 ? Math.round(totalAgeDays / totalProducts) : 0;

    // Top 4 categories by stock units, remainder rolled into "Others"
    let categoryList = Object.entries(categoryStockMap)
      .map(([name, units]) => ({ name, units }))
      .sort((a, b) => b.units - a.units);

    const topCategories = categoryList.slice(0, 4);
    const otherUnits = categoryList.slice(4).reduce((sum, c) => sum + c.units, 0);
    if (otherUnits > 0) {
      topCategories.push({ name: "Others", units: otherUnits });
    }

    const categoryDistribution = topCategories.map((c) => ({
      label: c.name,
      units: c.units,
      percent:
        totalStockUnits > 0
          ? Math.round((c.units / totalStockUnits) * 1000) / 10
          : 0,
    }));

    // Low stock alerts
    const lowStockProducts = products
      .filter((p) => (p.stock || 0) <= (p.lowStockThreshold ?? 5))
      .sort((a, b) => (a.stock || 0) - (b.stock || 0));

    const lowStockAlerts = lowStockProducts.slice(0, 5).map((p) => ({
      id: p._id,
      name: p.name,
      sku: p.sku,
      stock: p.stock || 0,
    }));

    // ---------------------------------------------------
    // WAREHOUSES / UTILIZATION
    // ---------------------------------------------------
    const warehouses = await Warehouse.find({ isActive: true }).lean();
    const warehouseCount = warehouses.length;
    const totalCapacity = warehouses.reduce((sum, w) => sum + (w.capacity || 0), 0);
    const utilizationPercent =
      totalCapacity > 0
        ? Math.round((totalStockUnits / totalCapacity) * 1000) / 10
        : 0;

    // ---------------------------------------------------
    // RECENT TRANSACTIONS
    // ---------------------------------------------------
    const recentSales = await Sale.find().sort({ createdAt: -1 }).limit(3);
    const recentPurchases = await Purchase.find().sort({ createdAt: -1 }).limit(3);

    // ---------------------------------------------------
    // RESPONSE
    // ---------------------------------------------------
    res.status(200).json({
      success: true,
      data: {
        todaysSales: {
          amount: todaySalesAmount,
          changePercent: percentChange(todaySalesAmount, yesterdaySalesAmount),
        },
        todaysPurchases: {
          amount: todayPurchasesAmount,
          changePercent: percentChange(todayPurchasesAmount, yesterdayPurchasesAmount),
        },
        todaysOrders: {
          count: todayOrdersCount,
          changePercent: percentChange(todayOrdersCount, yesterdayOrdersCount),
        },
        pendingPayments: {
          amount: pendingPaymentsAmount,
          changePercent: percentChange(pendingLast7Total, pendingPrev7Total),
        },
        warehouseAnalytics: {
          stockValue: totalStockValue,
          utilizationPercent,
          totalItems: totalStockUnits,
          avgStockAgeDays,
        },
        categoryDistribution,
        totalStockUnits,
        lowStockAlerts,
        lowStockCount: lowStockProducts.length,
        warehouseCount,
        recentSales,
        recentPurchases,
      },
    });
  } catch (error) {
    console.error("DASHBOARD SUMMARY ERROR");
    console.error(error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
